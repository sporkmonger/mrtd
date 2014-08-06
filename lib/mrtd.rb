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

class MRTD
  def initialize(ocr_text)
    @ocr_text = ocr_text
  end

  def mrz
    if !defined?(@mrz) || @mrz == nil
      mrz_text
    end
    @mrz
  end

private
  def mrz_text
    filtered = @ocr_text.gsub(/[^0-9A-Za-z<\n]/, '')
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
    candidates.detect { |c| (@mrz = MRZ.new(c)) rescue nil }
  end
end
