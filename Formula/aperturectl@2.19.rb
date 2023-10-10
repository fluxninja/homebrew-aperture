class AperturectlAT219 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/v2.19.2-rc.1.tar.gz"
  sha256 "4e2e0a5d5c4e0c2dbc53fd5e4ba34f08d15ce1d6ba24ace3d86d0cf31439d165"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "stable/v2.19.x"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl@2.19-2.19.1"
    sha256 cellar: :any_skip_relocation, monterey:     "adc219e587f87be51ba349c101215300b78daaada6bedb7607ace438c6b45145"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "ab1c351664414ecad764e1e766b0b6c794d1d470dfe2e73f5b8ada2c4a15113a"
  end

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    git_branch="stable/v2.19.x"
    git_commit_hash="1829c579af924d2474a2557d1cb12cebacd134a3"

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
