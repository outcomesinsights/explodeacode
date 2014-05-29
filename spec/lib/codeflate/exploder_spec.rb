require_relative '../../../lib/codeflate/exploder'
describe Codeflate::Exploder, '#results' do
  describe 'with ICD-9s' do
    it 'takes finds 412 as 412 only' do
      expect(Codeflate::Exploder.new({vocabulary: 'ICD-9'}, 412).results).to eql(['412'])
    end

    it 'takes 584 and yields nothing since the code does not exist' do
      expect(Codeflate::Exploder.new({vocabulary: 'ICD-9'}, 584).results).to eql([])
    end

    it 'takes 584.% and yields all sub categories of 584' do
      expect(Codeflate::Exploder.new({vocabulary: 'ICD-9'}, '584.%').results).to eql(["584.5", "584.6", "584.7", "584.8", "584.9"])
    end

    it 'takes 410.?1 and yields all variants of 410 with fifth digit of 1' do
      expect(Codeflate::Exploder.new({vocabulary: 'ICD-9'}, '410.?1').results).to eql(["410.01", "410.11", "410.21", "410.31", "410.41", "410.51", "410.61", "410.71", "410.81", "410.91"])
    end

    it 'takes 584.% ~584.7 and yields all variants of 584 without 584.7' do
      expect(Codeflate::Exploder.new({vocabulary: 'ICD-9'}, '584.%', '~584.7').results).to eql(["584.5", "584.6", "584.8", "584.9"])
    end

    it 'takes 584%..586% and yields all variants of 584, 585, 586' do
      expect(Codeflate::Exploder.new({vocabulary: 'ICD-9'}, '584%..586%').results).to eql(["584.5", "584.6", "584.7", "584.8", "584.9", "585.1", "585.2", "585.3", "585.4", "585.5", "585.6", "585.9", "586"])
    end

    it 'takes 410.?1..411.?1 and yields all variants of 410.?1 and 411.?1' do
      expect(Codeflate::Exploder.new({vocabulary: 'ICD-9'}, '410.?1..411.?1').results).to eql(["410.01", "410.11", "410.21", "410.31", "410.41", "410.51", "410.61", "410.71", "410.81", "410.91", "411.81"])
    end

    it 'takes 410.?/1..411.?/1 and yields all five digit 410, 411 that end in 1 and all four digit 410, 411' do
      expect(Codeflate::Exploder.new({vocabulary: 'ICD-9'}, '410.?/1..411.?/1').results).to eql(["410.0", "410.01", "410.1", "410.11", "410.2", "410.21", "410.3", "410.31", "410.4", "410.41", "410.5", "410.51", "410.6", "410.61", "410.7", "410.71", "410.8", "410.81", "410.9", "410.91", "411.0", "411.1", "411.8", "411.81"])
    end
  end

  describe 'with ICD-10s' do
    it 'takes I11.% and yields all matches for I11' do
      expect(Codeflate::Exploder.new({vocabulary: 'ICD-10'}, 'I11.%').results).to eql(['I11.0', 'I11.9'])
    end
    it 'takes I11 and yields no matches since it does not exist' do
      expect(Codeflate::Exploder.new({vocabulary: 'ICD-10'}, 'I11').results).to eql([])
    end
  end
end
