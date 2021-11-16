require "../../../spec_helper"

module Ameba::Rule::Performance
  subject = MapInsteadOfBlock.new

  describe MapInsteadOfBlock do
    it "passes if there is no potential performance improvements" do
      expect_no_issues subject, <<-CRYSTAL
        (1..3).sum(&.*(2))
        (1..3).product(&.*(2))
        CRYSTAL
    end

    it "reports if there is map followed by sum without a block" do
      source = Source.new %(
        (1..3).map(&.to_u64).sum
      )
      subject.catch(source).should_not be_valid
    end

    it "does not report if source is a spec" do
      expect_no_issues subject, <<-CRYSTAL
        (1..3).map(&.to_s).join
        CRYSTAL
    end

    it "reports if there is map followed by sum without a block (with argument)" do
      source = Source.new %(
        (1..3).map(&.to_u64).sum(0)
      )
      subject.catch(source).should_not be_valid
    end

    it "reports if there is map followed by sum with a block" do
      source = Source.new %(
        (1..3).map(&.to_u64).sum(&.itself)
      )
      subject.catch(source).should_not be_valid
    end

    context "macro" do
      it "doesn't report in macro scope" do
        expect_no_issues subject, <<-CRYSTAL
          {{ [1, 2, 3].map(&.to_u64).sum }}
          CRYSTAL
      end
    end

    it "reports rule, pos and message" do
      s = Source.new %(
        (1..3).map(&.to_u64).sum
      ), "source.cr"
      subject.catch(s).should_not be_valid
      issue = s.issues.first

      issue.rule.should_not be_nil
      issue.location.to_s.should eq "source.cr:1:8"
      issue.end_location.to_s.should eq "source.cr:1:25"
      issue.message.should eq "Use `sum {...}` instead of `map {...}.sum`"
    end
  end
end
