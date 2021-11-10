require "../../../spec_helper"

module Ameba::Rule::Performance
  describe Base do
    subject = PerfRule.new

    describe "#catch" do
      it "ignores spec files" do
        expect_no_issues subject, "", "source_spec.cr"
      end

      it "reports perf issues for non-spec files" do
        expect_issue subject, <<-CRYSTAL

          # ^{} error: Poor performance
          CRYSTAL
      end
    end
  end
end
