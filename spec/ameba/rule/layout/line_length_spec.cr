require "../../../spec_helper"

module Ameba::Rule::Layout
  subject = LineLength.new
  subject.max_length = 15

  describe LineLength do
    it "passes if all lines are shorter than MaxLength symbols" do
      expect_no_issues subject, "short line"
    end

    it "passes if line consists of MaxLength symbols" do
      expect_no_issues subject, "max length line"
    end

    it "fails if there is at least one line longer than MaxLength symbols" do
      source = expect_issue subject, <<-CRYSTAL
        extremely long line
                     # ^ error: Line too long
        CRYSTAL

      expect_no_corrections source
    end

    context "properties" do
      it "allows to configure max length of the line" do
        rule = LineLength.new
        rule.max_length = 20
        expect_no_issues rule, "extremely long line"
      end
    end
  end
end
