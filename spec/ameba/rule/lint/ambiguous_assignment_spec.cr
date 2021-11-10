require "../../../spec_helper"

module Ameba::Rule::Lint
  describe AmbiguousAssignment do
    subject = AmbiguousAssignment.new

    context "when using `-`" do
      it "reports an issue with `x`" do
        source = expect_issue subject, <<-CRYSTAL
          x =- y
          # ^^ error: Suspicious assignment detected. Did you mean `-=`?
          CRYSTAL

        expect_no_corrections source
      end

      it "reports an issue with `@x`" do
        source = expect_issue subject, <<-CRYSTAL
          @x =- y
           # ^^ error: Suspicious assignment detected. Did you mean `-=`?
          CRYSTAL

        expect_no_corrections source
      end

      it "reports an issue with `@@x`" do
        source = expect_issue subject, <<-CRYSTAL
          @@x =- y
            # ^^ error: Suspicious assignment detected. Did you mean `-=`?
          CRYSTAL

        expect_no_corrections source
      end

      it "reports an issue with `X`" do
        source = expect_issue subject, <<-CRYSTAL
          X =- y
          # ^^ error: Suspicious assignment detected. Did you mean `-=`?
          CRYSTAL

        expect_no_corrections source
      end

      it "does not report an issue when no mistype assignments" do
        expect_no_issues subject, <<-CRYSTAL
          x = 1
          x -= y
          x = -y
          CRYSTAL
      end
    end

    context "when using `+`" do
      it "reports an issue with `x`" do
        source = expect_issue subject, <<-CRYSTAL
          x =+ y
          # ^^ error: Suspicious assignment detected. Did you mean `+=`?
          CRYSTAL

        expect_no_corrections source
      end

      it "reports an issue with `@x`" do
        source = expect_issue subject, <<-CRYSTAL
          @x =+ y
           # ^^ error: Suspicious assignment detected. Did you mean `+=`?
          CRYSTAL

        expect_no_corrections source
      end

      it "reports an issue with `@@x`" do
        source = expect_issue subject, <<-CRYSTAL
          @@x =+ y
            # ^^ error: Suspicious assignment detected. Did you mean `+=`?
          CRYSTAL

        expect_no_corrections source
      end

      it "reports an issue with `X`" do
        source = expect_issue subject, <<-CRYSTAL
          X =+ y
          # ^^ error: Suspicious assignment detected. Did you mean `+=`?
          CRYSTAL

        expect_no_corrections source
      end

      it "does not report an issue when no mistype assignments" do
        expect_no_issues subject, <<-CRYSTAL
          x = 1
          x += y
          x = +y
          CRYSTAL
      end
    end

    context "when using `!`" do
      it "reports an issue with `x`" do
        source = expect_issue subject, <<-CRYSTAL
          x =! y
          # ^^ error: Suspicious assignment detected. Did you mean `!=`?
          CRYSTAL

        expect_no_corrections source
      end

      it "reports an issue with `@x`" do
        source = expect_issue subject, <<-CRYSTAL
          @x =! y
           # ^^ error: Suspicious assignment detected. Did you mean `!=`?
          CRYSTAL

        expect_no_corrections source
      end

      it "reports an issue with `@@x`" do
        source = expect_issue subject, <<-CRYSTAL
          @@x =! y
            # ^^ error: Suspicious assignment detected. Did you mean `!=`?
          CRYSTAL

        expect_no_corrections source
      end

      it "reports an issue with `X`" do
        source = expect_issue subject, <<-CRYSTAL
          X =! y
          # ^^ error: Suspicious assignment detected. Did you mean `!=`?
          CRYSTAL

        expect_no_corrections source
      end

      it "does not report an issue when no mistype assignments" do
        expect_no_issues subject, <<-CRYSTAL
          x = false
          x != y
          x = !y
          CRYSTAL
      end
    end
  end
end
