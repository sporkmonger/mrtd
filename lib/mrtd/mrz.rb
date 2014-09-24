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


require 'date'

class MRTD
  class MRZ
    EXPECTED_LINE_LENGTHS = [44, 36, 34, 30]
    COUNTRY_CODES = %w{
      ABW AFG AGO AIA ALA ALB AND ANT ARE ARG ARM ASM ATA ATF ATG AUS AUT AZE
      BDI BEL BEN BFA BGD BGR BHR BHS BIH BLR BLZ BMU BOL BRA BRB BRN BRU BTN
      BVT BWA CAF CAN CCK CDN CHE CHL CHN CIV CMR COD COG COK COL COM CPV CRI
      CUB CUW CXR CYM CYP CZE D<< DEU DJI DMA DNK DOM DZA EAK ECU EGY ERI ESH
      ESP EST ETH FIN FJI FLK FRA FRO FSM FXX GAB GBD GBN GBO GBP GBR GBS GCA
      GEO GGY GHA GIB GIN GLP GMB GNB GNQ GRC GRD GRL GTM GUF GUM GUY HKG HMD
      HND HRV HTI HUN IDN IMN IND IOT IRL IRN IRQ ISL ISR ITA JAM JEY JOR JPN
      KAZ KEN KGZ KHM KIR KNA KOR KWT KYA LAO LBN LBR LBY LCA LIE LKA LSO LTU
      LUX LVA MAC MAL MAR MCO MDA MDG MDV MEX MHL MKD MLI MLT MMR MNG MNP MOZ
      MRT MSR MTQ MUS MWI MYS MYT NAM NCL NER NFK NGA NIC NIU NLD NOR NPL NRU
      NTZ NZL OMN PAK PAN PCN PER PHL PLW PNG POL PRI PRK PRT PRY PSE PYF QAT
      RCA REU ROC ROK ROU RUS RWA SAU SCG SDN SEN SGP SGS SHN SI< SJM SLB SLE
      SLV SMR SOM SPM SSD STP SUR SVK SVN SWE SWZ SXM SYC SYR TCA TCD TGO THA
      TJK TKL TKM TLS TMP TON TTO TUN TUR TUV TWN TZA UGA UKR UMI UNA UNK UNO
      URY USA UZB VAT VCT VEN VGB VIR VNM VUT WAL WLF WSM XOM XXA XXB XXC XXX
      YEM ZAF ZMB ZWE
    }
    COUNTRY_WEIGHTING = {
      'ABW' => 102911,
      'AFG' => 29117000,
      'AGO' => 18993000,
      'AIA' => 13600,
      'ALA' => 28666,
      'ALB' => 3195000,
      'AND' => 84082,
      'ANT' => 227049,
      'ARE' => 4707000,
      'ARG' => 40518951,
      'ARM' => 3238000,
      'ASM' => 55519,
      'ATA' => 5000,
      'ATF' => 140,
      'ATG' => 89000,
      'AUS' => 23480970,
      'AUT' => 8372930,
      'AZE' => 8997400,
      'BDI' => 8519000,
      'BEL' => 10827519,
      'BEN' => 9212000,
      'BFA' => 16287000,
      'BGD' => 164425000,
      'BGR' => 7576751,
      'BHR' => 807000,
      'BHS' => 346000,
      'BIH' => 3760000,
      'BLR' => 9471900,
      'BLZ' => 322100,
      'BMU' => 64237,
      'BOL' => 10031000,
      'BRA' => 193364000,
      'BRB' => 257000,
      'BRN' => 407000,
      'BRU' => 407000,
      'BTN' => 708000,
      'BVT' => 0,
      'BWA' => 1978000,
      'CAF' => 4506000,
      'CAN' => 34207000,
      'CCK' => 596,
      'CHE' => 7782900,
      'CHL' => 17114000,
      'CHN' => 1339190000,
      'CIV' => 21571000,
      'CMR' => 19958000,
      'COD' => 67827000,
      'COG' => 3759000,
      'COK' => 19569,
      'COL' => 45569000,
      'COM' => 691000,
      'CPV' => 513000,
      'CRI' => 4640000,
      'CUB' => 11204000,
      'CUW' => 151892,
      'CXR' => 2072,
      'CYM' => 56732,
      'CYP' => 801851,
      'CZE' => 10512397,
      'D<<' => 81757600,
      'DEU' => 81757600,
      'DJI' => 879000,
      'DMA' => 67000,
      'DNK' => 5540241,
      'DOM' => 10225000,
      'DZA' => 35423000,
      'EAK' => 40863000,
      'ECU' => 14228000,
      'EGY' => 78848000,
      'ERI' => 5224000,
      'ESH' => 548000,
      'ESP' => 46951532,
      'EST' => 1340021,
      'ETH' => 79221000,
      'FIN' => 5366100,
      'FJI' => 854000,
      'FLK' => 2932,
      'FRA' => 65447374,
      'FRO' => 49709,
      'FSM' => 111000,
      'FXX' => 63660000,
      'GAB' => 1501000,
      'GBD' => 62041708,
      'GBN' => 62041708,
      'GBO' => 62041708,
      'GBP' => 62041708,
      'GBR' => 62041708,
      'GBS' => 62041708,
      'GCA' => 14377000,
      'GEO' => 4436000,
      'GGY' => 65345,
      'GHA' => 24333000,
      'GIB' => 30001,
      'GIN' => 10324000,
      'GLP' => 405739,
      'GMB' => 1751000,
      'GNB' => 1647000,
      'GNQ' => 693000,
      'GRC' => 11306183,
      'GRD' => 104000,
      'GRL' => 56968,
      'GTM' => 14377000,
      'GUF' => 250109,
      'GUM' => 159358,
      'GUY' => 761000,
      'HKG' => 7184000,
      'HMD' => 0,
      'HND' => 7616000,
      'HRV' => 4435056,
      'HTI' => 10188000,
      'HUN' => 10013628,
      'IDN' => 234181400,
      'IMN' => 84497,
      'IND' => 1184639000,
      'IOT' => 3000,
      'IRL' => 4459300,
      'IRN' => 75078000,
      'IRQ' => 31467000,
      'ISL' => 317900,
      'ISR' => 7602400,
      'ITA' => 60340328,
      'JAM' => 2730000,
      'JEY' => 97857,
      'JOR' => 6472000,
      'JPN' => 127380000,
      'KAZ' => 16197000,
      'KEN' => 40863000,
      'KGZ' => 5550000,
      'KHM' => 13395682,
      'KIR' => 100000,
      'KNA' => 38960,
      'KOR' => 49773145,
      'KWT' => 3051000,
      'KYA' => 40863000,
      'LAO' => 6436000,
      'LBN' => 4255000,
      'LBR' => 3476608,
      'LBY' => 6546000,
      'LCA' => 174000,
      'LIE' => 35904,
      'LKA' => 20410000,
      'LSO' => 2084000,
      'LTU' => 3329227,
      'LUX' => 502207,
      'LVA' => 2237800,
      'MAC' => 2048620,
      'MAL' => 28306700,
      'MAR' => 31892000,
      'MCO' => 33000,
      'MDA' => 3563800,
      'MDG' => 21146000,
      'MDV' => 314000,
      'MEX' => 108396211,
      'MHL' => 63000,
      'MKD' => 2058539,
      'MLI' => 14517176,
      'MLT' => 416333,
      'MMR' => 50496000,
      'MNG' => 2768800,
      'MNP' => 77000,
      'MOZ' => 23406000,
      'MRT' => 3366000,
      'MSR' => 5164,
      'MTQ' => 386486,
      'MUS' => 1297000,
      'MWI' => 15692000,
      'MYS' => 28306700,
      'MYT' => 212645,
      'NAM' => 2212000,
      'NCL' => 256000,
      'NER' => 15891000,
      'NFK' => 2302,
      'NGA' => 170123000,
      'NIC' => 5822000,
      'NIU' => 1611,
      'NLD' => 16609518,
      'NOR' => 4896700,
      'NPL' => 29853000,
      'NRU' => 10000,
      'NTZ' => 0,
      'NZL' => 4383600,
      'OMN' => 2905000,
      'PAK' => 170260000,
      'PAN' => 3322576,
      'PCN' => 56,
      'PER' => 29461933,
      'PHL' => 94013200,
      'PLW' => 20000,
      'PNG' => 6888000,
      'POL' => 38167329,
      'PRI' => 3667084,
      'PRK' => 23991000,
      'PRT' => 10636888,
      'PRY' => 6460000,
      'PSE' => 4550368,
      'PYF' => 268270,
      'QAT' => 1696563,
      'RCA' => 4506000,
      'REU' => 840974,
      'ROC' => 23373517,
      'ROK' => 49773145,
      'ROU' => 21466174,
      'RUS' => 141927297,
      'RWA' => 10277000,
      'SAU' => 26246000,
      'SCG' => 9856000,
      'SDN' => 31894000,
      'SEN' => 12861000,
      'SGP' => 4987600,
      'SGS' => 30,
      'SHN' => 7729,
      'SI<' => 2062700,
      'SJM' => 0,
      'SLB' => 536000,
      'SLE' => 5836000,
      'SLV' => 6194000,
      'SMR' => 32386,
      'SOM' => 9359000,
      'SPM' => 6080,
      'SSD' => 8260490,
      'STP' => 165000,
      'SUR' => 524000,
      'SVK' => 5426645,
      'SVN' => 2062700,
      'SWE' => 9366092,
      'SWZ' => 1202000,
      'SXW' => 37429,
      'SYC' => 85000,
      'SYR' => 22505000,
      'TCA' => 31458,
      'TCD' => 11274106,
      'TGO' => 6780000,
      'THA' => 63525062,
      'TJK' => 7075000,
      'TKL' => 1411,
      'TKM' => 5177000,
      'TLS' => 1171000,
      'TMP' => 1171000,
      'TON' => 104000,
      'TTO' => 1344000,
      'TUN' => 10432500,
      'TUR' => 72561312,
      'TUV' => 10000,
      'TWN' => 23373517,
      'TZA' => 45040000,
      'UGA' => 33796000,
      'UKR' => 45871738,
      'UMI' => 300,
      'UNA' => 10000,
      'UNK' => 1733842,
      'UNO' => 10000,
      'URY' => 3372000,
      'USA' => 309975000,
      'UZB' => 27794000,
      'VAT' => 800,
      'VCT' => 109000,
      'VEN' => 28888000,
      'VGB' => 27800,
      'VIR' => 106405,
      'VNM' => 85789573,
      'VUT' => 246000,
      'WAL' => 5836000,
      'WLF' => 15500,
      'WSM' => 179000,
      'XOM' => 90000,
      'XXA' => 10000,
      'XXB' => 10000,
      'XXC' => 10000,
      'XXX' => 10000,
      'YEM' => 24256000,
      'ZAF' => 49991300,
      'ZMB' => 13257000,
      'ZWE' => 12644000,
    }
    AMBIGUOUS_CHARACTERS = {
      '<' => [],
      '0' => ['O', 'D', 'C', 'G', 'Q', '8'],
      '1' => ['I', 'L'],
      '2' => ['R', 'S', 'Z'],
      '3' => ['8', 'B', '5'],
      '4' => [],
      '5' => ['S', 'B', '3'],
      '6' => [],
      '7' => [],
      '8' => ['B', '0'],
      '9' => [],
      'A' => [],
      'B' => ['8', 'E', 'D', '5'],
      'C' => ['G', 'O', '0', 'D'],
      'D' => ['O', 'B', '0', 'G', 'C'],
      'E' => ['F', 'B'],
      'F' => ['P', 'E'],
      'G' => ['C', 'Q', '0', 'O'],
      'H' => [],
      'I' => ['1', 'L'],
      'J' => ['L', 'I'],
      'K' => ['R'],
      'L' => ['I', '1', 'J'],
      'M' => ['W', 'N'],
      'N' => ['V', 'W', 'M'],
      'O' => ['0', 'D', 'C', 'G', 'Q'],
      'P' => ['F', 'R'],
      'Q' => ['G', '0', 'O', 'C'],
      'R' => ['K', 'P'],
      'S' => ['5', '2'],
      'T' => [],
      'U' => ['V'],
      'V' => ['U', 'N', 'W', 'Y'],
      'W' => ['M', 'V', 'N'],
      'X' => [],
      'Y' => ['V'],
      'Z' => ['2']
    }

    def initialize(text)
      if text.respond_to?(:to_str)
        @text = text.to_str
      else
        raise ArgumentError, "Expected String, got #{text.class}"
      end
      normalize_text!
      normalize_document_code!
      normalize_issuing_country!
      normalize_name!
      normalize_document_number_check_digit!
      normalize_document_number!
      normalize_date_of_birth_check_digit!
      normalize_date_of_birth!
      normalize_gender!
      normalize_document_date_check_digit!
      normalize_document_date!
      normalize_nationality!
      normalize_optional_data_element!
    end

    attr_reader :text

    def normalize_text!
      raise ArgumentError, "Missing MRZ text." if @text.nil?
      candidate = @text.dup
      candidate_lines = candidate.strip.split("\n")
      line_count = candidate_lines.count
      line_lengths = candidate_lines.map(&:length)

      seen = Hash.new(0)
      line_lengths.each { |value| seen[value] += 1 }
      max = seen.values.max
      line_length = seen.find_all do |key,value|
        value == max
      end.map { |key, value| key }

      if !EXPECTED_LINE_LENGTHS.include?(line_length)
        line_length = line_lengths.detect do |ll|
          EXPECTED_LINE_LENGTHS.include?(ll)
        end
      end
      if EXPECTED_LINE_LENGTHS.include?(line_length)
        @text = candidate_lines.map do |line|
          stripped_line = line.upcase.gsub(/[^0-9A-Z<]/, '')
          if stripped_line.length != line_length
            break
          end
          stripped_line.strip + "\n"
        end.join('')
        return if @text && @text != ''
      end
      squashed_candidate = candidate.gsub(/[\s\n]/, '')
      squashed_passport_regexp = /[PA].[A-Z<]{3}.{39}.{10}[A-Z<]{3}.{7}[MFX<].{7}.{15}[0-9<]/
      squashed_passport = squashed_candidate[squashed_passport_regexp, 0]
      if squashed_passport && squashed_passport != ''
        @text = "#{squashed_passport[0...44]}\n#{squashed_passport[44...88]}\n"
        return
      end
      squashed_id_regexp = /[AIC].[A-Z<]{3}.{25}[0-9<]{7}[MFX<][0-9<]{7}.{14}[0-9<].{30}/
      squashed_id = squashed_candidate[squashed_id_regexp, 0]
      if squashed_id && squashed_id != ''
        @text = "#{squashed_id[0...30]}\n#{squashed_id[30...60]}\n#{squashed_id[60...90]}\n"
        return
      end
    end
    private :normalize_text!

    def document_format
      lines = @text.strip.split("\n")
      if lines.count == 2 && lines[0].length == 44
        return :passport
      elsif lines.count == 3 && lines[0].length == 30 &&
          document_code == 'ID' && issuing_country == 'KYA' &&
          @text[46] == '<'
        return :td1_ken
      elsif lines.count == 3 && lines[0].length == 30
        return :td1
      elsif lines.count == 1 && lines[0].length == 30
        return :td1_single
      elsif lines.count == 2 && lines[0].length == 36 &&
          document_code == 'ID' && issuing_country == 'FRA' &&
          @text[71] =~ /^[MF<X]$/
        return :td2_fra
      elsif lines.count == 2 && lines[0].length == 36
        return :td2
      elsif lines.count == 2 && lines[0].length == 34
        return :td2_34
      end
    end

    def document_code
      return @text[0...2]
    end

    def normalize_document_code!
      first = document_code[0]
      second = document_code[1]
      if !['P', 'I', 'A', 'V', 'C', 'T'].include?(first)
        first = (['P', 'I', 'A', 'V', 'C', 'T'] & AMBIGUOUS_CHARACTERS[first]).first
        if !first.nil?
          @text[0] = first
        else
          raise ArgumentError,
            "Expected P, I, A, V, C, or T type document, got '#{first}'"
        end
      end
      if document_code == 'IV'
        raise ArgumentError, "'IV' is an invalid document code."
      end
      return document_code
    end
    private :normalize_document_code!

    def issuing_country
      return @text[2...5]
    end

    def normalize_issuing_country!
      code = issuing_country
      if COUNTRY_CODES.include?(code)
        return code
      else
        candidate_countries = []
        patterns = [1,1,0].permutation.map do |mask|
          Regexp.new('^' + code.split('').zip(mask).map do |(char, bit)|
            if (bit == 1 || AMBIGUOUS_CHARACTERS[char].empty?)
              char
            else
              "[#{AMBIGUOUS_CHARACTERS[char].join('')}]"
            end
          end.join('') + '$')
        end.uniq
        if patterns.empty?
          patterns = [1,1,0].permutation.map do |mask|
            Regexp.new('^' + code.split('').zip(mask).map do |(char, bit)|
              bit == 1 ? char : '.'
            end.join('') + '$')
          end.uniq
        end
        candidate_countries = COUNTRY_CODES.select do |code|
          patterns.any? { |pattern| code =~ pattern }
        end
        candidate_weights = candidate_countries.map do |code|
          COUNTRY_WEIGHTING[code]
        end
        index = candidate_weights.index(candidate_weights.max)
        if index
          return @text[2...5] = candidate_countries[index]
        else
          return code
        end
      end
    end
    private :normalize_issuing_country!

    def name
      case document_format
      when :passport
        name_string = @text[5..43]
      when :td1, :td1_ken
        name_string = @text[62..91]
      when :td2
        name_string = @text[5..35]
      when :td2_fra
        name_string = @text[5..29] + @text[50..63]
      when :td2_34
        name_string = @text[5..33]
      end
      return name_string
    end

    def normalize_name!
      name_string = name.dup
      if name_string =~ /[0-9]/
        name_string.gsub!(/[0-9]/) do |char|
          AMBIGUOUS_CHARACTERS[char].detect { |c| c !~ /^[0-9]$/ }
        end
        case document_format
        when :passport
          @text[5..43] = name_string
        when :td1, :td1_ken
          @text[62..91] = name_string
        when :td2
          @text[5..35] = name_string
        when :td2_fra
          # Why, France, why?
          @text[5..35] = name_string[0..25]
          @text[50..63] = name_string[25..38]
        when :td2_34
          @text[5..33] = name_string
        end
      else
        return name_string
      end
    end
    private :normalize_name!

    def date_of_birth
      case document_format
      when :passport
        dob_string = @text[58..63]
      when :td1, :td1_ken
        dob_string = @text[31..36]
      when :td2
        dob_string = @text[50..55]
      when :td2_fra
        dob_string = @text[64..69]
      when :td2_34
        dob_string = @text[48..53]
      end
      fields = dob_string.scan(/../).map { |f| f.to_i }
      fields.map! { |f| f == 0 ? 1 : f }
      dob = Date.new(fields[0] + 2000, fields[1], fields[2])
      if dob.year > Time.now.year
        # DOB cannot be in the future, assume Y2K bug.
        dob = Date.new(dob.year - 100, dob.month, dob.day)
      end
      dob
    end

    def normalize_date_of_birth!
      case document_format
      when :passport
        dob_string = @text[58..63]
      when :td1, :td1_ken
        dob_string = @text[31..36]
      when :td2
        dob_string = @text[50..55]
      when :td2_fra
        dob_string = @text[64..69]
      when :td2_34
        dob_string = @text[48..53]
      end

      new_dob_string = MRZ.conditional_permute(
        dob_string,
        /^[0-9<]{2}[01<][0-9<][0-3<][0-9<]$/,
        date_of_birth_check_digit,
        [
          lambda do |val, _, _|
            subfields = val.split(/../).map(&:to_i)
            date = Date.new(*subfields) rescue nil
            if date
              date <= Date.today
            else
              false
            end
          end
        ]
      )

      case document_format
      when :passport
        @text[58..63] = new_dob_string
      when :td1, :td1_ken
        @text[31..36] = new_dob_string
      when :td2
        @text[50..55] = new_dob_string
      when :td2_fra
        @text[64..69] = new_dob_string
      when :td2_34
        @text[48..53] = new_dob_string
      end
    end
    private :normalize_date_of_birth!

    def date_of_birth_check_digit
      case document_format
      when :passport
        @text[64]
      when :td1, :td1_ken
        @text[37]
      when :td2
        @text[56]
      when :td2_fra
        @text[70]
      when :td2_34
        @text[54]
      end
    end

    def normalize_date_of_birth_check_digit!
      digit = date_of_birth_check_digit
      if digit =~ /^[0-9]$/
        return digit
      else
        digit = (
          AMBIGUOUS_CHARACTERS[digit].detect { |c| c =~ /^[0-9]$/ } ||
          digit
        )
        case document_format
        when :passport
          @text[64] = digit
        when :td1, :td1_ken
          @text[37] = digit
        when :td2
          @text[56] = digit
        when :td2_fra
          @text[70] = digit
        when :td2_34
          @text[54] = digit
        end
      end
    end

    def gender
      case document_format
      when :passport
        gender_string = @text[65]
      when :td1, :td1_ken
        gender_string = @text[38]
      when :td2
        gender_string = @text[57]
      when :td2_fra
        gender_string = @text[71]
      when :td2_34
        gender_string = @text[55]
      end
      case gender_string
      when 'M'
        return :male
      when 'F'
        return :female
      when '<', 'X'
        return :unspecified
      else
        raise ArgumentError,
          "Unexpected character in gender field: '#{gender_string}'"
      end
    end

    def normalize_gender!
      begin
        return gender
      rescue ArgumentError => e
        case document_format
        when :passport
          gender_string = @text[65]
        when :td1, :td1_ken
          gender_string = @text[38]
        when :td2
          gender_string = @text[57]
        when :td2_fra
          gender_string = @text[71]
        when :td2_34
          gender_string = @text[55]
        end
        possible_characters = AMBIGUOUS_CHARACTERS[gender_string]
        gender_string = (['M', 'F', '<', 'X'] & possible_characters).first
        if !gender_string.nil?
          case document_format
          when :passport
            @text[65] = gender_string
          when :td1, :td1_ken
            @text[38] = gender_string
          when :td2
            @text[57] = gender_string
          when :td2_fra
            @text[71] = gender_string
          when :td2_34
            @text[55] = gender_string
          end
          return gender_string
        else
          raise e
        end
      end
    end
    private :normalize_gender!

    def document_date
      case document_format
      when :passport
        date_string = @text[66..71]
      when :td1, :td1_ken
        date_string = @text[39..44]
      when :td2
        date_string = @text[58..63]
      when :td2_fra
        # Again, why, France, why?
        # Document issue date is year, month only, and tacked on front of ID #.
        date_string = @text[37..40] + '01'
      when :td2_34
        date_string = @text[56..61]
      end
      fields = date_string.scan(/../).map { |f| f.to_i }
      fields.map! { |f| f == 0 ? 1 : f }
      doc_date = Date.new(fields[0] + 2000, fields[1], fields[2])
      if doc_date.year > Time.now.year + 50
        # Document date should not be more than 50 years in the future
        doc_date = Date.new(doc_date.year - 100, doc_date.month, doc_date.day)
      elsif doc_date.year < Time.now.year - 50
        # Document date should not be more than 50 years in the past
        doc_date = Date.new(doc_date.year + 100, doc_date.month, doc_date.day)
      end
      doc_date
    end

    def normalize_document_date!
      case document_format
      when :passport
        date_string = @text[66..71]
      when :td1, :td1_ken
        date_string = @text[39..44]
      when :td2
        date_string = @text[58..63]
      when :td2_fra
        # Do nothing.
        return nil
      when :td2_34
        date_string = @text[56..61]
      end

      new_date_string = MRZ.conditional_permute(
        date_string,
        /^[0-9<]{2}[01<][0-9<][0-3<][0-9<]$/,
        document_date_check_digit,
        [
          lambda do |val, _, _|
            subfields = val.split(/../).map(&:to_i)
            !!(Date.new(*subfields)) rescue false
          end
        ]
      )

      case document_format
      when :passport
        @text[66..71] = new_date_string
      when :td1, :td1_ken
        @text[39..44] = new_date_string
      when :td2
        @text[58..63] = new_date_string
      when :td2_34
        @text[56..61] = new_date_string
      end
    end
    private :normalize_document_date!

    def document_date_check_digit
      case document_format
      when :passport
        @text[72]
      when :td1, :td1_ken
        @text[45]
      when :td2
        @text[64]
      when :td2_fra
        # Do nothing.
        return nil
      when :td2_34
        @text[62]
      end
    end

    def normalize_document_date_check_digit!
      digit = document_date_check_digit
      if digit.nil?
        return digit
      elsif digit =~ /^[0-9]$/
        return digit
      else
        digit = (
          AMBIGUOUS_CHARACTERS[digit].detect { |c| c =~ /^[0-9]$/ } ||
          digit
        )
        case document_format
        when :passport
          @text[72] = digit
        when :td1, :td1_ken
          @text[45] = digit
        when :td2
          @text[64] = digit
        when :td2_fra
          # Do nothing.
          return nil
        when :td2_34
          @text[62] = digit
        end
      end
    end
    private :normalize_document_date_check_digit!

    def document_number
      case document_format
      when :passport
        @text[45..53]
      when :td1, :td1_ken
        @text[5..13]
      when :td2
        @text[37..45]
      when :td2_fra
        @text[37..48]
      when :td2_34
        @text[35..43]
      end
    end

    def normalize_document_number!
      pattern = nil
      case [document_code + issuing_country, document_format]
      when ['P<ERI', :passport]
        pattern = /^[0-9A-Z][0-9<]{8}$/
      when ['P<FRA', :passport]
        pattern = /^[0-9A-Z]{9}$/
      when ['IDFRA', :td2_fra]
        pattern = /^[0-9]{4}[0-9A-Z]{8}$/
      when ['P<GBR', :passport]
        pattern = /^[0-9]{9}$/
      when ['IDGBR', :td1]
        pattern = /^[0-9A-Z]{3}[0-9]{6}$/
      when ['P<ISR', :passport]
        pattern = /^[0-9]{8}[0-9<]$/
      when ['P<KEN', :passport]
        pattern = /^[0-9A-Z][0-9<]{8}$/
      when ['PAKEN', :passport]
        pattern = /^[0-9A-Z][0-9<]{8}$/
      when ['A5KEN', :passport]
        pattern = /^[0-9A-Z][0-9<]{8}$/
      when ['IDKYA', :td1_ken]
        pattern = /^[0-9<]{9}$/
      when ['PPZAF', :passport]
        pattern = /^[0-9]{9}$/
      when ['PMCHE', :passport]
        pattern = /^[0-9A-Z][0-9<]{8}$/
      when ['P<USA', :passport]
        pattern = /^[0-9]{9}$/
      when ['IGUSA', :td1]
        pattern = /^[0-9]{9}$/
      when ['PCUGA', :passport]
        pattern = /^[0-9A-Z][0-9<]{8}$/
      end
      if pattern
        new_document_string = MRZ.conditional_permute(
          document_number,
          pattern,
          document_number_check_digit
        )

        case document_format
        when :passport
          @text[45..53] = new_document_string
        when :td1, :td1_ken
          @text[5..13] = new_document_string
        when :td2
          @text[37..45] = new_document_string
        when :td2_fra
          @text[37..48] = new_document_string
        when :td2_34
          @text[35..43] = new_document_string
        end
      end
    end
    private :normalize_document_number!

    def document_number_check_digit
      case document_format
      when :passport
        @text[54]
      when :td1, :td1_ken
        @text[14]
      when :td2
        @text[46]
      when :td2_fra
        @text[49]
      when :td2_34
        @text[44]
      end
    end

    def normalize_document_number_check_digit!
      digit = document_number_check_digit
      if digit =~ /^[0-9]$/
        return digit
      else
        digit = (
          AMBIGUOUS_CHARACTERS[digit].detect { |c| c =~ /^[0-9]$/ } ||
          digit
        )
        case document_format
        when :passport
          @text[54] = digit
        when :td1, :td1_ken
          @text[14] = digit
        when :td2
          @text[46] = digit
        when :td2_fra
          @text[49] = digit
        when :td2_34
          @text[44] = digit
        end
      end
    end
    private :normalize_document_number_check_digit!

    def nationality
      case document_format
      when :passport
        @text[55..57]
      when :td1
        @text[46..48]
      when :td1_ken
        # Do nothing.
        return nil
      when :td2
        @text[41..43]
      when :td2_fra
        # Do nothing.
        return nil
      when :td2_34
        @text[41..43]
      end
    end

    def normalize_nationality!
      code = nationality
      if code.nil?
        return code
      elsif COUNTRY_CODES.include?(code)
        return code
      else
        candidate_countries = []
        patterns = [1,1,0].permutation.map do |mask|
          Regexp.new('^' + code.split('').zip(mask).map do |(char, bit)|
            if (bit == 1 || AMBIGUOUS_CHARACTERS[char].empty?)
              char
            else
              "[#{AMBIGUOUS_CHARACTERS[char].join('')}]"
            end
          end.join('') + '$')
        end.uniq
        if patterns.empty?
          patterns = [1,1,0].permutation.map do |mask|
            Regexp.new('^' + code.split('').zip(mask).map do |(char, bit)|
              bit == 1 ? char : '.'
            end.join('') + '$')
          end.uniq
        end
        candidate_countries = COUNTRY_CODES.select do |code|
          patterns.any? { |pattern| code =~ pattern }
        end
        candidate_weights = candidate_countries.map do |code|
          COUNTRY_WEIGHTING[code]
        end
        index = candidate_weights.index(candidate_weights.max)
        if index
          case document_format
          when :passport
            return @text[55..57] = candidate_countries[index]
          when :td1
            return @text[46..48] = candidate_countries[index]
          when :td1_ken
            # Do nothing.
            return nil
          when :td2
            return @text[41..43] = candidate_countries[index]
          when :td2_fra
            # Do nothing.
            return nil
          when :td2_34
            return @text[41..43] = candidate_countries[index]
          end
        else
          return code
        end
      end
    end
    private :normalize_nationality!

    def optional_data_elements
      case document_format
      when :passport
        [@text[73..86]]
      when :td1
        [@text[15..29], @text[49..59]]
      when :td1_ken
        [@text[15..29], @text[46..59]]
      when :td2
        [@text[65..71]]
      when :td2_fra
        [@text[30..35]]
      when :td2_34
        [@text[63..67]]
      end
    end

    def optional_data_element_check_digit
      case document_format
      when :passport
        @text[87]
      when :td1
        # Do nothing.
        return nil
      when :td1_ken
        # Do nothing.
        return nil
      when :td2
        # Do nothing.
        return nil
      when :td2_fra
        # Do nothing.
        return nil
      when :td2_34
        # Do nothing.
        return nil
      end
    end

    def normalize_optional_data_element!
      data_element = optional_data_elements.last
      if optional_data_element_check_digit.nil? ||
          data_element =~ /^<+$/
        return nil
      end
      if document_format == :passport
        case issuing_country
        when 'USA'
          pattern = /^[0-9<]{14}$/
        when 'UTO'
          pattern = /^[0-9A-Z<]{9}[<]{5}$/
        else
          return nil
        end
        new_optional_data_element_string = MRZ.conditional_permute(
          data_element,
          pattern,
          optional_data_element_check_digit
        )
        @text[73..86] = new_optional_data_element_string
      end
    end
    private :normalize_optional_data_element!

    def composite_value
      case document_format
      when :passport
        @text[45..54] + @text[58..64] + @text[66..87]
      when :td1
        @text[5..29] + @text[31..37] + @text[39..45] + @text[49..59]
      when :td1_ken
        @text[5..29] + @text[31..37] + @text[39..45] + @text[46..59]
      when :td2
        @text[37..46] + @text[50..56] + @text[58..71]
      when :td2_fra
        return @text[0..71].gsub(/\s/, '')
      when :td2_34
        return @text[35..67]
      end
    end

    def composite_value_check_digit
      case document_format
      when :passport
        @text[88]
      when :td1
        @text[60]
      when :td2
        @text[72]
      when :td2_fra
        @text[72]
      when :td2_34
        @text[68]
      end
    end

    def split
      case document_format
      when :passport
        [
          @text[0], @text[1], @text[2..4], @text[5..43],
          @text[45..53], @text[54], @text[55..57], @text[58..63], @text[64],
          @text[65], @text[66..71], @text[72], @text[73..86], @text[87],
          @text[88]
        ]
      when :td1
        [
          @text[0], @text[1], @text[2..4], @text[5..13], @text[14],
          @text[15..29], @text[31..36], @text[37], @text[38], @text[39..44],
          @text[45], @text[46..59], @text[60], @text[62..91]
        ]
      when :td2
      when :td2_fra
        [
          @text[0], @text[1], @text[2..4], @text[5..29], @text[30..35],
          @text[37..48], @text[49], @text[50..63], @text[64..69], @text[70],
          @text[71], @text[72]
        ]
      when :td2_34
      end
    end

    def self.find_composite_values(mrz_list)
      format = mrz_list.first.document_format
      if !mrz_list.all? { |mrz| mrz.document_format }
        raise ArgumentError, "All MRZs in the list must be of the same format."
      end
      mask_size = mrz_list.first.split.length
      masks = [0,1].repeated_permutation(mask_size)
      mrz_candidates = {}

      for mrz in mrz_list
        mrz_candidates[mrz] = []

        for mask in masks
          candidate = mrz.split.zip(mask).select do |string, selector|
            selector == 1
          end.map(&:first).join('')
          next if candidate == ''
          digit = MRZ.generate_check_digit(candidate)
          if digit == mrz.composite_value_check_digit
            mrz_candidates[mrz] << mask
          end
        end
      end

      matches = mrz_candidates.values.first
      for candidate_set in mrz_candidates.values
        matches &= candidate_set
      end

      for mask in matches
        for mrz in mrz_list
          candidate = mrz.split.zip(mask).select do |string, selector|
            selector == 1
          end.map(&:first).join('')
          # puts candidate
        end
        # puts '-----'
      end
    end

#   MRTD::MRZ.new(<<-MRZ),
# IDKYA2054235171<<141<<<<<<<141
# 7805031M9612165<B020666953P<<4
# SAMUEL<KARIUKI<GACHUI<<<<<<<<<
# MRZ
#   MRTD::MRZ.new(<<-MRZ),
# IDKYA2145367837<<162<<<<<<<451
# 8310062M0201070<B022873275N<<6
# JOHN<WAINAINA<SAMSON<KARANJA<<
# MRZ

# candidates = MRTD::MRZ.find_composite_values([
#   MRTD::MRZ.new(<<-MRZ),
# IDKYA2211448620<<111<<<<<<<161
# 63<<<<1M0611073<B007253274X<<0
# JOSIAH<GITHINJI<<<<<<<<<<<<<<<
# MRZ
#   MRTD::MRZ.new(<<-MRZ),
# IDKYA2242580229<<334<<<<<<<161
# 8812186M0806257<B026073206A<<3
# FRED<KIMANTHI<KITHINZI<<<<<<<<
# MRZ
#   MRTD::MRZ.new(<<-MRZ),
# IDKYA2244207993<<121<<<<<<<314
# 8806116M0712051<B027223961A<<1
# ZACCHAEUS<MURIITHI<MUNENE<<<<<
# MRZ
# ])

# candidates = MRTD::MRZ.find_composite_values([
#   MRTD::MRZ.new(<<-MRZ),
# IDFRAMORARD<LACROIX<<<<<<<<<<<75S001
# 100575S006796YVES<<ALAIN<<J6005306M4
# MRZ
#   MRTD::MRZ.new(<<-MRZ),
# IDFRAPETE<<<<<<<<<<<<<<<<<<<<<952042
# 0509952018746NICOLAS<<PAUL<8206152M3
# MRZ
#   MRTD::MRZ.new(<<-MRZ),
# IDFRACONSTANT<<<<<<<<<<<<<<<<<<<<<<<
# 000675C001559ASTRID<<CAMILL7907290F9
# MRZ
# ])

    ##
    # Implementation from http://rosettacode.org/wiki/Levenshtein_distance#Ruby
    # Note: Removed downcasing.
    def self.levenshtein_distance(a, b)
      costs = Array(0..b.length) # i == 0
      (1..a.length).each do |i|
        costs[0], nw = i, i - 1  # j == 0; nw is lev(i-1, j)
        (1..b.length).each do |j|
          costs[j], nw = [costs[j] + 1, costs[j-1] + 1, a[i-1] == b[j-1] ? nw : nw + 1].min, costs[j]
        end
      end
      costs[b.length]
    end

    ##
    # OCR processes frequently have errors which must be compensated for.
    # This method attempts to reconstruct the original data fields using hints
    # and success criteria. It assumes the field input is of the correct field
    # length.
    #
    # @example
    #   MRTD::MRZ.conditional_permute(
    #     '82D2D8',
    #     /^[0-9<]{2}[01<][0-9<][0-3<][0-9<]$/,
    #     '4',
    #     [
    #       lambda do |val, _, _|
    #         subfields = val.split(/../).map(&:to_i)
    #         date = Date.new(*subfields) rescue nil
    #         if date
    #           date <= Date.today
    #         else
    #           false
    #         end
    #       end
    #     ]
    #   )
    #   # => '820208'
    #
    #   MRTD::MRZ.conditional_permute(
    #     '<<<',
    #     /^[A-Z]{3}$/,
    #     '0',
    #     [
    #       lambda do |val, _, _|
    #         false
    #       end
    #     ]
    #   )
    #   # => '<<<'
    def self.conditional_permute(field,
        field_pattern=/^[A-Z0-9<]+$/, check_digit=nil, conditions=[])
      if field =~ field_pattern &&
          (check_digit == nil || self.generate_check_digit(field) == check_digit) &&
          conditions.all? { |cond| cond.call(field, field_pattern, check_digit) }
        # Short circuit, field value is already acceptable
        return field
      end
      field_chars = field.strip.split('')
      indices = [0] * field_chars.count
      all_chars = field_chars.map { |char| [char, *AMBIGUOUS_CHARACTERS[char]] }
      candidates = []
      completed = false
      # Loop until we overflow the most-significant digit's place
      while !completed
        # Yes, this variable naming is hella-confusing.
        # The other way round is worse.
        candidate = indices.each_with_index.map do |index, digit|
          all_chars[digit][index]
        end.join('')
        if candidate =~ field_pattern &&
            (check_digit == nil || self.generate_check_digit(candidate) == check_digit) &&
            conditions.all? { |cond| cond.call(candidate, field_pattern, check_digit) }
          # We've got a match for all success conditions!
          if self.levenshtein_distance(candidate, field) == 1
            # And it's a single-character change!
            return candidate
          else
            candidates << candidate
          end
        end
        # Increment the least-significant digit's place, then carry
        indices[-1] += 1
        for i in (0...indices.length).to_a.reverse
          if indices[i] >= all_chars[i].length
            # We've overflowed, reset to 0 and carry the 1
            indices[i] = 0
            # If we're already at the most-significant digit, do nothing.
            # This exits the outer loop.
            if i > 0
              indices[i - 1] += 1
            else
              completed = true
              break
            end
          end
        end
      end
      # Choose the candidate with the smallest levenshtein distance from the
      # supplied erroneous input field value.
      if candidates.count > 0
        best_distance = nil
        best_candidate = nil
        for candidate in candidates
          distance = self.levenshtein_distance(candidate, field)
          if best_distance == nil || best_distance > distance
            best_distance = distance
            best_candidate = candidate
          end
        end
        return best_candidate
      end
      # We failed and couldn't find anything
      return field
    end

    CHECK_DIGIT_TABLE = (
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('').inject({}) do |a, char|
        a[char] = a.size
        a
      end.merge('<' => 0)
    )

    DOCUMENT_PATTERNS = {
      /^IGUSA/ => <<-DOC,
  Itiii#########CNNNNNNNNNNNNNNN
  YYMMDDCsyymmddCbbbpppppppppppX
  nnnnnnnnnnnnnnnnnnnnnnnnnnnnnn
  DOC
      /^IDKYA/ => <<-DOC,
  Itiii#########Cppppppppppppppp
  YYMMDDCsyymmddCNNNNNNNNNNNNNNX
  nnnnnnnnnnnnnnnnnnnnnnnnnnnnnn
  DOC
      /^IDFRA/ => <<-DOC,
  Itiiillllllllllllllllllllllllldddooo
  ############CffffffffffffffYYMMDDCsX
  DOC
      /^P..../ => <<-DOC,
  Ptiiinnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn
  #########CbbbYYMMDDCsyymmddCppppppppppppppCX
  DOC
      /^I..../ => <<-DOC,
  Itiii#########CNNNNNNNNNNNNNNN
  YYMMDDCsyymmddCbbbpppppppppppX
  nnnnnnnnnnnnnnnnnnnnnnnnnnnnnn
  DOC
    }
    DEFAULT_PATTERN = <<-DOC
  Ptiiinnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn
  #########CbbbYYMMDDCsyymmddCppppppppppppppCX
  DOC
    CHECK_DIGIT_RANGES = {
      /^IGUSA/ => {
        14 => [5..13],
        36 => [30..35],
        44 => [38..43],
        59 => [5..36, 38..44, 48..58]
      },
      /^IDFRA/ => {
        48 => [36..47],
        69 => [63..68],
        71 => [0..70]
      },
      /^TD2/ => {
        45 => [36..44],
        55 => [49..54],
        63 => [57..62],
        71 => [36..45, 49..55, 57..70]
      },
      /^IDKYA/ => {
        14 => [5..13],
        36 => [30..35],
        44 => [38..43],
        59 => [5..14,30..36,38..58]

        #[5..14,30..36,38..58]

        #[5..14,15..29,30..36,37..37,38..44,45..58]

        #[5..14, 30..59]
        #[5..14, 30..36, 38..58]
        #[5..36, 38..44, 48..58]
        #[5..36, 38..58]
      },
      /^P..../ => {
        53 => [44..52],
        63 => [57..62],
        71 => [65..70],
        86 => [72..85],
        87 => [44..53, 57..63, 65..86]
      },
      /^I..../ => {
        14 => [5..13],
        36 => [30..35],
        44 => [38..43],
        59 => [5..36, 38..44, 48..58]
      }
    }
    DEFAULT_DIGIT_RANGE = {
      53 => [44..52],
      63 => [57..62],
      71 => [65..70],
      86 => [72..85],
      87 => [44..53, 57..63, 65..86]
    }

    def self.match_five(text, patterns, fallback=nil)
      return (
        patterns[Regexp.new(Regexp.escape(text[0...5]))] or
        # Too clever by half.
        # See http://www.ruby-doc.org/core-2.1.1/Enumerable.html#method-i-detect
        # Particularly the ifnone parameter.
        patterns.detect(lambda {[]}) { |k, _| text[0...5] =~ k }.last or
        fallback
      )
    end

    def self.generate_all_check_digits(text)
      text = text.gsub(/\s/, '')
      digit_ranges = match_five(text, CHECK_DIGIT_RANGES, DEFAULT_DIGIT_RANGE)
      text_ranges = digit_ranges.inject({}) do |a, (digit_index, digit_range_seq)|
        a[digit_index] = digit_range_seq.inject('') do |sa, digit_range|
          sa += text[digit_range]
          sa
        end
        a
      end
      text_ranges.inject({}) do |a, (digit_index, string)|
        a[digit_index] = generate_check_digit(string)
        a
      end
    end

    def self.extract_mrz(text)
      if text.respond_to?(:to_str)
        text = text.to_str
      else
        raise TypeError, "Expected String, got #{text.class}."
      end

    end

    def self.extract_data(text)
      if text.respond_to?(:to_str)
        text = text.to_str
      else
        raise TypeError, "Expected String, got #{text.class}."
      end
      pattern = match_five(text, DOCUMENT_PATTERNS, DEFAULT_PATTERN)
      text_lines = text.strip.split("\n")
      pattern_lines = pattern.strip.split("\n")
      if text_lines.count != pattern_lines.count
        raise ArgumentError, (
          "Expected #{pattern_lines.count} line MRZ, " +
          "got #{text_lines.count} line MRZ."
        )
      end
      last_pattern_char = nil
      current_width = 0
      pattern_widths = []
      pattern.split('').each_with_index do |char, index|
        last_pattern_char = char if last_pattern_char.nil?
        if char != last_pattern_char && current_width > 0
          pattern_widths << current_width
          current_width = 0
        end
        if char != "\n"
          last_pattern_char = char
          current_width += 1
        end
      end
      text = text.gsub(/\s/, '')
      slices = []
      index = 0
      pattern_widths.each do |width|
        slice = text[index...(index + width)]
        slices << slice
        index += width
      end
      slices
    end

    def self.generate_check_digit(value)
      if value !~ /^[a-zA-Z0-9<]+$/
        raise ArgumentError, "Value must be alphanumeric or '<'."
      end
      chars = value.upcase.split('')
      return (chars.each.with_index.inject(0) do |sum,(char,index)|
        weight_sequence = 2 - (index % 3)
        weight = (weight_sequence + 1) ** 2 - weight_sequence
        char_value = CHECK_DIGIT_TABLE[char]
        sum += weight * char_value
        sum
      end % 10).to_s
    end
  end
end
