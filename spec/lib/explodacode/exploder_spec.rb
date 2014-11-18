require_relative '../../../lib/explodacode/exploder'
describe Explodacode::Exploder, '#results' do
  describe 'with ICD-9s' do
    before do
      @exploder = Explodacode::Exploder.new({vocabulary: 'ICD-9'})
    end

    it 'takes finds 412 as 412 only' do
      expect(@exploder.blow_up(412)).to eql(['412'])
    end

    it 'takes 584 and yields nothing since the code does not exist' do
      expect(@exploder.blow_up(584)).to eql([])
    end

    it 'takes 584.% and yields all sub categories of 584' do
      expect(@exploder.blow_up('584.%')).to eql(["584.5", "584.6", "584.7", "584.8", "584.9"])
    end

    it 'takes 410.?1 and yields all variants of 410 with fifth digit of 1' do
      expect(@exploder.blow_up('410.?1')).to eql(["410.01", "410.11", "410.21", "410.31", "410.41", "410.51", "410.61", "410.71", "410.81", "410.91"])
    end

    it 'takes 584.% ~584.7 and yields all variants of 584 without 584.7' do
      expect(@exploder.blow_up('584.%', '~584.7')).to eql(["584.5", "584.6", "584.8", "584.9"])
    end

    it 'takes 584%..586% and yields all variants of 584, 585, 586' do
      expect(@exploder.blow_up('584%..586%')).to eql(["584.5", "584.6", "584.7", "584.8", "584.9", "585.1", "585.2", "585.3", "585.4", "585.5", "585.6", "585.9", "586"])
    end

    it 'takes 410.?1..411.?1 and yields all variants of 410.?1 and 411.?1' do
      expect(@exploder.blow_up('410.?1..411.?1')).to eql(["410.01", "410.11", "410.21", "410.31", "410.41", "410.51", "410.61", "410.71", "410.81", "410.91", "411.81"])
    end

    it 'takes 410.?/1..411.?/1 and yields all five digit 410, 411 that end in 1 and all four digit 410, 411' do
      expect(@exploder.blow_up('410.?/1..411.?/1')).to eql(["410.0", "410.01", "410.1", "410.11", "410.2", "410.21", "410.3", "410.31", "410.4", "410.41", "410.5", "410.51", "410.6", "410.61", "410.7", "410.71", "410.8", "410.81", "410.9", "410.91", "411.0", "411.1", "411.8", "411.81"])
    end
  end

  describe 'with ICD-10s' do
    before do
      @exploder = Explodacode::Exploder.new({vocabulary: 'ICD-10'})
    end

    it 'takes I11.% and yields all matches for I11' do
      expect(@exploder.blow_up('I11.%')).to eql(['I11.0', 'I11.9'])
    end

    it 'takes I11 and yields no matches since it does not exist' do
      expect(@exploder.blow_up('I11')).to eql([])
    end
  end

  describe 'with CPT' do
    before do
      @exploder = Explodacode::Exploder.new({vocabulary: 'CPT'})
    end

    it 'takes 9921? and yields all matches for 9921*' do
      expect(@exploder.blow_up('9921?')).to eql(["99211", "99212", "99213", "99214", "99215", "99217", "99218", "99219"])
    end

    it 'takes 9921% and yields all matches for 9921*' do
      expect(@exploder.blow_up('9921%')).to eql(["99211", "99212", "99213", "99214", "99215", "99217", "99218", "99219"])
    end

    it 'takes 9921%..9922% and yields all matches for 9921* and 9922*' do
      expect(@exploder.blow_up('9921%..9922%')).to eql(["99211", "99212", "99213", "99214", "99215", "99217", "99218", "99219", "99220", "99221", "99222", "99223", "99224", "99225", "99226"])
    end
  end
end
