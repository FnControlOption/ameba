require "../../../spec_helper"

module Ameba::Rule::Performance
  subject = FirstLastAfterFilter.new

  describe FirstLastAfterFilter do
    it "passes if there is no potential performance improvements" do
      expect_no_issues subject, <<-CRYSTAL
        [1, 2, 3].select { |e| e > 1 }
        [1, 2, 3].reverse.select { |e| e > 1 }
        [1, 2, 3].reverse.last
        [1, 2, 3].reverse.first
        [1, 2, 3].reverse.first
        CRYSTAL
    end

    it "reports if there is select followed by last" do
      source = Source.new %(
        [1, 2, 3].select { |e| e > 2 }.last
      )
      subject.catch(source).should_not be_valid
    end

    it "does not report if source is a spec" do
      expect_no_issues subject, <<-CRYSTAL, "source_spec.cr"
        [1, 2, 3].select { |e| e > 2 }.last
        CRYSTAL
    end

    it "reports if there is select followed by last?" do
      source = Source.new %(
        [1, 2, 3].select { |e| e > 2 }.last?
      )
      subject.catch(source).should_not be_valid
    end

    it "reports if there is select followed by first" do
      source = Source.new %(
        [1, 2, 3].select { |e| e > 2 }.first
      )
      subject.catch(source).should_not be_valid
    end

    it "does not report if there is selected followed by first with arguments" do
      expect_no_issues subject, <<-CRYSTAL
        [1, 2, 3].select { |n| n % 2 == 0 }.first(2)
        CRYSTAL
    end

    it "reports if there is select followed by first?" do
      source = Source.new %(
        [1, 2, 3].select { |e| e > 2 }.first?
      )
      subject.catch(source).should_not be_valid
    end

    it "does not report if there is select followed by any other call" do
      expect_no_issues subject, <<-CRYSTAL
        [1, 2, 3].select { |e| e > 2 }.size
        [1, 2, 3].select { |e| e > 2 }.any?
        CRYSTAL
    end

    context "properties" do
      it "allows to configure object_call_names" do
        rule = Rule::Performance::FirstLastAfterFilter.new
        rule.filter_names = %w(reject)
        expect_no_issues rule, <<-CRYSTAL
          [1, 2, 3].select { |e| e > 2 }.first
          CRYSTAL
      end
    end

    it "reports rule, pos and message" do
      s = Source.new %(
        [1, 2, 3].select { |e| e > 2 }.first
      ), "source.cr"
      subject.catch(s).should_not be_valid
      s.issues.size.should eq 1

      issue = s.issues.first
      issue.rule.should_not be_nil
      issue.location.to_s.should eq "source.cr:1:11"
      issue.end_location.to_s.should eq "source.cr:1:37"

      issue.message.should eq "Use `find {...}` instead of `select {...}.first`"
    end

    it "reports a correct message for first?" do
      s = Source.new %(
        [1, 2, 3].select { |e| e > 2 }.first?
      ), "source.cr"
      subject.catch(s).should_not be_valid
      s.issues.size.should eq 1

      issue = s.issues.first
      issue.rule.should_not be_nil
      issue.location.to_s.should eq "source.cr:1:11"
      issue.end_location.to_s.should eq "source.cr:1:38"

      issue.message.should eq "Use `find {...}` instead of `select {...}.first?`"
    end

    it "reports rule, pos and reverse message" do
      s = Source.new %(
        [1, 2, 3].select { |e| e > 2 }.last
      ), "source.cr"
      subject.catch(s).should_not be_valid
      s.issues.size.should eq 1

      issue = s.issues.first
      issue.rule.should_not be_nil
      issue.location.to_s.should eq "source.cr:1:11"
      issue.end_location.to_s.should eq "source.cr:1:36"

      issue.message.should eq "Use `reverse_each.find {...}` instead of `select {...}.last`"
    end

    context "macro" do
      it "doesn't report in macro scope" do
        expect_no_issues subject, <<-CRYSTAL
          {{[1, 2, 3].select { |e| e > 2  }.last }}
          CRYSTAL
      end
    end

    it "reports a correct message for last?" do
      s = Source.new %(
        [1, 2, 3].select { |e| e > 2 }.last?
      ), "source.cr"
      subject.catch(s).should_not be_valid
      s.issues.size.should eq 1

      issue = s.issues.first
      issue.rule.should_not be_nil
      issue.location.to_s.should eq "source.cr:1:11"
      issue.end_location.to_s.should eq "source.cr:1:37"

      issue.message.should eq "Use `reverse_each.find {...}` instead of `select {...}.last?`"
    end
  end
end
