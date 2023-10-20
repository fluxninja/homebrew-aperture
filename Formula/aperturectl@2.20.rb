class AperturectlAT220 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/v2.20.2-rc.1.tar.gz"
  sha256 "6ac58ddf22f783ee53eb9e5e0388d49b940ac8ca8c7989b839314045fe13474c"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "stable/v2.20.x"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl@2.20-2.20.1"
    sha256 cellar: :any_skip_relocation, monterey:     "c6c19b5e431cb3aa980ac371b21b961b33e741a2332eb9b523d8744ac63036c4"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "0f7114b9d4589d50e4094758a94fad558f3209ab92792f05aaa3915c7203777c"
  end

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    git_branch="stable/v2.20.x"
    git_commit_hash="6f0c4e269273659249bdbad68c7c97288db42611"

    require "open3"
    if build.head?
      head_branch="stable/v2.20.x"
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
