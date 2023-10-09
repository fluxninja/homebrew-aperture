class AperturectlAT219 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/v2.19.1-rc.1.tar.gz"
  sha256 "d31fc4f6774557f00ee743991d8c9f1a1fd230594bf17e64f39f04d1c9725039"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "stable/v2.19.x"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl@2.19-2.19.1-rc.1"
    sha256 cellar: :any_skip_relocation, monterey:     "14fb9f2649db5c87ea9302bd46687b25432c840620fd3d989b0b612d00900a24"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "f250833b7acc61cc5416cc801bc51652af35fffe38241fcb769bd7129c7f8310"
  end

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    git_branch="stable/v2.19.x"
    git_commit_hash="6fda852fed4bb0ab46d90b661c79871803f418ae"

    require "open3"
    if build.head?
      head_branch="stable/v2.19.x"
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
