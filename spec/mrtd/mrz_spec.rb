require File.expand_path("../spec_helper.rb", File.dirname(__FILE__))

describe MRTD::MRZ do
  it 'should calculate check digits correctly' do
    expect(subject.generate_check_digit('AB2134<<<')).to eql('5')
    expect(subject.generate_check_digit('0123456789')).to eql('7')
    expect(subject.generate_check_digit('9876543210')).to eql('3')
    expect(subject.generate_check_digit('HELLO<WORLD')).to eql('0')
    expect(subject.generate_check_digit(
      'THE<QUICK<BROWN<FOX<JUMPED<OVER<THE<LAZY<DOG'
    )).to eql('5')
  end

#   context 'with a TD1 national ID card from "Utopia"' do
#     let(:mrz_text) do
#       <<-MRZ
# I<UTOD231458907<<<<<<<<<<<<<<<
# 3407127M9507122UTO<<<<<<<<<<<2
# DOE<<JOHN<<<<<<<<<<<<<<<<<<<<<
# MRZ
#     end

#     it 'should extract data from MRZ text correctly' do
#       expect(subject.extract_data(mrz_text)).to eql([
#         "I", "<", "UTO", "D23145890", "7", "<<<<<<<<<<<<<<<",
#         "34", "07", "12", "7", "M", "95", "07", "12", "2", "UTO", "<<<<<<<<<<<",
#         "2", "DOE<<JOHN<<<<<<<<<<<<<<<<<<<<<"
#       ])
#     end

#     it 'should generate check digits from MRZ text correctly' do
#       expect(subject.generate_all_check_digits(mrz_text)).to eql({
#         14=>"7", 36=>"7", 44=>"2", 59=>"2"
#       })
#     end
#   end

#   context 'with a TD2 national ID card from "Utopia"' do
#     let(:mrz_text) do
#       <<-MRZ
# I<UTODOE<<JOHN<<<<<<<<<<<<<<<<<<<<<<
# HA672242<6UTO5802254M9601086<<<<<<<8
# MRZ
#     end

#     it 'should extract data from MRZ text correctly' do
#       expect(subject.extract_data(mrz_text)).to eql([
#         "I", "<", "UTO", "D23145890", "7", "<<<<<<<<<<<<<<<",
#         "34", "07", "12", "7", "M", "95", "07", "12", "2", "UTO", "<<<<<<<<<<<",
#         "2", "DOE<<JOHN<<<<<<<<<<<<<<<<<<<<<"
#       ])
#     end

#     it 'should generate check digits from MRZ text correctly' do
#       expect(subject.generate_all_check_digits(mrz_text)).to eql({
#         45=>"7", 36=>"7", 44=>"2", 59=>"2"
#       })
#     end
#   end

  context 'with a passport from Kenya' do
    let(:mrz_text) do
      <<-MRZ
PAKENKENNETH<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<<
L898902C<3UTO6908061F9406236ZE184226B<<<<<14
MRZ
    end

    it 'should extract data from MRZ text correctly' do
      expect(subject.extract_data(mrz_text)).to eql([
        "P", "A", "KEN", "KENNETH<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<<",
        "L898902C<", "3", "UTO", "69", "08", "06", "1", "F",
        "94", "06", "23", "6", "ZE184226B<<<<<", "1", "4"
      ])
    end
  end

  context 'with a Global Entry card from the USA' do
    let(:mrz_text) do
      <<-MRZ
IGUSA1234567897987654321<<<<<<
4203142M1803149USA<<<<<<<<<<<4
ADAMS<<FRANKLIN<<<<<<<<<<<<<<<
MRZ
    end

    it 'should extract data from MRZ text correctly' do
      expect(subject.extract_data(mrz_text)).to eql([
        "I", "G", "USA", "123456789", "7", "987654321<<<<<<",
        "42", "03", "14", "2", "M", "18", "03", "14", "9", "USA", "<<<<<<<<<<<",
        # Unsure about reverse engineering here; this should be either 4 or 5.
        # Probably 4, but 5 would be smarter (both lines).
        "4",
        "ADAMS<<FRANKLIN<<<<<<<<<<<<<<<"
      ])
    end
  end

  context 'with a national ID card from Kenya' do
    let(:mrz_text) do
      <<-MRZ
IDKYA6541239871<<334<<<<<<<141
8806150M0902230<B543216789A<<8
GACHUI<<DANIEL<<<<<<<<<<<<<<<<
MRZ
    end

    it 'should extract data from MRZ text correctly' do
      expect(subject.extract_data(mrz_text)).to eql([
        "I", "D", "KYA", "654123987", "1", "<<334<<<<<<<141",
        "88", "06", "15", "0", "M", "09", "02", "23", "0", "<B543216789A<<",
        "8", "GACHUI<<DANIEL<<<<<<<<<<<<<<<<"
      ])
    end
  end
end
