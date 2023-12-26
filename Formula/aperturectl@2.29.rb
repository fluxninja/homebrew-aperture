class AperturectlAT229 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.29.0-rc.1.tar.gz"
  sha256 "79be51ea56849f595a4e7097ed7e10883f23798dc10491b64b790730496459aa"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl@2.29-2.29.0-rc.1"
    sha256 cellar: :any_skip_relocation, monterey: "735b1bed51437bfa52cb6c546592cfcd58afd0b1a5322e619415855961b4bc46"
  end

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    git_branch="stable/v2.29.x"
    git_commit_hash="4f64b1df86f2a93d63b4620559002138abe1b708"

    require "open3"
    if build.head?
      head_branch="stable/v2.29.x"
      stdout, status = Open3.capture2("git", "log", "-n1", "--format=%H")
      odie "Unable to get commit hash for head build" if status != 0
      git_commit_hash=stdout
      git_branch=head_branch
    end

    ENV["APERTURECTL_BUILD_VERSION"]=version
    ENV["APERTURECTL_BUILD_GIT_BRANCH"]=git_branch
    ENV["APERTURECTL_BUILD_GIT_COMMIT_HASH"]=git_commit_hash

    stdout, status = Open3.capture2("./scripts/build_aperturectl.sh", buildpath/"cmd/aperturectl")
    odie "Failed to build aperturectl" if status != 0

    # Move the binary into the final location
    makedirs bin
    mv stdout, bin/"aperturectl"

    generate_completions_from_executable(bin/"aperturectl", "completion")
  end

  test do
    assert_match "aperturectl version #{version}", shell_output("#{bin}/aperturectl --version")
  end
end
