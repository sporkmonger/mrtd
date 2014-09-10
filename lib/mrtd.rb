# Copyright 2014 BitPesa
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

require 'mrtd/version'
require 'mrtd/mrz'
require 'tempfile'
require 'fileutils'

class MRTD
  def initialize(image_path)
    @image_path = image_path
    @mrz_box = MRTD.process_mrz(image_path)
    @mrz_ocr_text = MRTD.collapse_box(@mrz_box)
    @mrz_text = mrz_text(@mrz_ocr_text)
    if !@mrz_text.nil?
      @mrz = MRZ.new(@mrz_text)
    else
      raise ArgumentError, "Could not locate MRZ:\n#{@mrz_ocr_text}"
    end
  end

  def viz
    raise NotImplementedError, 'TODO!'
  end

  attr_reader :mrz

# private
  def self.process_mrz(image_path)
    output_e = tesseract(image_path, ['-l eng', 'mrz', 'makebox'])
    output_p = tesseract(image_path, ['-l passport', 'mrz', 'makebox'])
    output_pe = tesseract(image_path, ['-l passport+eng', 'mrz', 'makebox'])
    output_ep = tesseract(image_path, ['-l eng+passport', 'mrz', 'makebox'])
    output_set = [output_e, output_p, output_pe, output_ep]
    return filter_mrz_box(concensus_box(output_set))
  end

  def self.tesseract(image_path, options=['-l passport', 'mrz', 'makebox'])
    image_ext = File.extname(image_path)
    output = image_path.gsub(/#{image_ext}$/, '')
    output_file = Tempfile.new([File.basename(output), '.box'])
    output_path = output_file.path
    tesseract_command = (
      'tesseract ' +
      image_path + ' ' +
      output_path.gsub(/\.box$/, '') + ' ' +
      options.join(' ')
    )
    # Silence all output.
    `#{tesseract_command} 2>&1`
    if $? && $?.exitstatus == 0
      result = File.read(output_path)
      output_file.close
      output_file.delete
      return result
    else
      output_file.close
      output_file.delete
      return nil
    end
  end

  def self.concensus_box(box_data_set)
    box_recognitions = {}
    for box_data in box_data_set
      for line in box_data.strip.split("\n")
        char, box = line.scan(/^(.) (\d+ \d+ \d+ \d+) \d$/).first
        box_recognitions[box] ||= []
        box_recognitions[box] << char
      end
    end
    new_box = ''
    majority_count = (box_data_set.count.to_f / 2.0).round
    box_concensus = {}
    for box, chars in box_recognitions
      if chars.count < majority_count
        # puts "#{box}: #{chars.inspect} failed to reach concensus."
        next
      end
      counts = chars.each_with_object(Hash.new(0)) { |c, acc| acc[c] += 1 }
      box_concensus[box] = counts.max_by { |k, v| v }.first
    end
    buffer = ''
    for box, char in box_concensus
      buffer += "#{char} #{box} 0\n"
    end
    buffer
  end

  def self.filter_mrz_box(box_data)
    upper_quartile = lambda do |ary|
      if ary.empty?
        nil
      else
        upper, rem = ary.length.divmod(4/3.to_f)
        if rem <= 0.01 && rem >= -0.01
          ary.sort[upper-1,2].inject(:+) / 2.0
        else
          ary.sort[upper]
        end
      end
    end
    box_recognitions = {}
    for line in box_data.strip.split("\n")
      char, box = line.scan(/^(.) (\d+ \d+ \d+ \d+) \d$/).first
      box = box.split(' ').map(&:to_i)
      box_recognitions[box] = char
    end
    width_avg, height_avg = (box_recognitions.inject([[], []]) do |acc, (box, _)|
      upper_left_x, upper_left_y, lower_right_x, lower_right_y = box
      width = lower_right_x - upper_left_x
      height = lower_right_y - upper_left_y
      acc[0] << width
      acc[1] << height
      acc
    end).map { |ary| upper_quartile.call(ary) }
    filtered_recognitions = {}
    for box, char in box_recognitions
      next if char == '~' # Toss out unidentified chars
      upper_left_x, upper_left_y, lower_right_x, lower_right_y = box
      width = lower_right_x - upper_left_x
      height = lower_right_y - upper_left_y
      if height.to_f / height_avg.to_f < 0.9
        next
      elsif width.to_f / width_avg.to_f < 0.35 && height.to_f / height_avg.to_f < 0.75
        next
      elsif width.to_f / width_avg.to_f < 0.55 && height.to_f / height_avg.to_f < 0.9 && char != 'I' && char != '1'
        next
      elsif width.to_f / width_avg.to_f < 0.50 && height.to_f / height_avg.to_f > 1.22 && char != 'I' && char != '1'
        next
      elsif width.to_f / width_avg.to_f < 0.60 && height.to_f / height_avg.to_f > 1.5 && char != 'I' && char != '1'
        next
      elsif width.to_f / height.to_f >= 0.90 && width.to_f / height.to_f <= 1.10 && char != 'M' && char != 'W' && char != '<'
        next
      end
      filtered_recognitions[box] = char
    end
    lines = split_lines(filtered_recognitions.to_a)
    buffer = ''
    lines.each do |line|
      line.each do |(box, char)|
        buffer += "#{char} #{box.join(' ')} 0\n"
      end
    end
    buffer
  end

  def self.split_lines(recognitions)
    median = lambda do |ary|
      if ary.empty?
        nil
      else
        upper, rem = ary.length.divmod(2)
        if rem == 0
          ary.sort[upper-1,2].inject(:+) / 2.0
        else
          ary.sort[upper]
        end
      end
    end
    lines = []
    unmatched_recognitions = recognitions.to_a.dup
    line_number = 0
    while !unmatched_recognitions.empty?
      lines[line_number] = [] if lines[line_number].nil?
      line = lines[line_number]
      if line.empty?
        line << unmatched_recognitions.shift
        next
      else
        upper_y = median.call(line.map { |box, _| _, upper_left_y, _, _ = box; upper_left_y })
        lower_y = median.call(line.map { |box, _| _, _, _, lower_right_y = box; lower_right_y })
        midavg_y = (upper_y + lower_y).to_f / 2.0
        matched = false
        unmatched_recognitions.each_with_index do |(box, char), index|
          _, upper_left_y, _, lower_right_y = box
          midbox_y = (upper_left_y + lower_right_y).to_f / 2.0
          # TODO: Figure out how to deal with slanted lines
          if (lower_right_y - lower_y).abs <= 6 ||
              (upper_left_y - upper_y).abs <= 6 ||
              (midbox_y - midavg_y).abs <= 3 ||
              ((lower_y..upper_y).include?(midbox_y) && (
                (lower_y..upper_y).include?(lower_right_y) ||
                (lower_y..upper_y).include?(upper_left_y)
              ))
            line << unmatched_recognitions.delete_at(index)
            matched = true
            break
          end
        end
        line_number += 1 if matched == false
      end
    end
    lines.each do |line|
      line.sort_by! { |(box, char)| box.first }
    end
    return lines
  end

  def self.collapse_box(box_data)
    box_recognitions = {}
    for line in box_data.strip.split("\n")
      char, box = line.scan(/^(.) (\d+ \d+ \d+ \d+) \d$/).first
      box = box.split(' ').map(&:to_i)
      box_recognitions[box] = char
    end
    lines = split_lines(box_recognitions.to_a)
    buffer = ''
    lines.each do |line|
      line.each do |(box, char)|
        buffer += char
      end
      buffer += "\n"
    end
    return buffer
  end

  def cached_mrzs
    @@cached_mrzs ||= {}
  end

  def mrz_text(ocr_text)
    filtered = ocr_text.gsub(/[^0-9A-Za-z<\n]/, '')
    lines = filtered.split(/\n+/)
    candidates = []
    lines.each_with_index do |line, i|
      window = lines[i...(i + 3)]
      possible = window.all? do |l|
        l.length <= line.length + 8 &&
        l.length >= line.length - 8 &&
        l.length >= 22 && l.length <= 52 &&
        window.count >= 2 && window.count <= 3
      end
      candidates << window.join("\n") if possible
    end
    # This is pretty inefficient because of the number of permutations needed.
    best_match = candidates.detect { |c| (cached_mrzs[c] ||= MRZ.new(c)) rescue nil }
    best_match = candidates.last unless best_match
    best_match
  end
end
