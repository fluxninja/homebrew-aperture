class Aperturectl < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.29.4.tar.gz"
  sha256 "27629dfe674aba58b94ca2aa7337e8b9ed9d2c2057d8ea96ce00111ce661ea92"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl-2.29.3"
    sha256 cellar: :any_skip_relocation, monterey:     "115f561246c9e4626f8db583ea23a7dcf660cd862dbec6bb0b20892aa9d9526a"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "abc05bebae9fc32e52008be36c065a582f48905ce14ba9e08db8eb04d53904c2"
  end

  depends_on "go" => :build

  def install
    git_branch="stable/v2.29.x"
    git_commit_hash="e506d1b1935e309b9305e3bc8e9ae0fc6a382264"

    require "open3"
    if build.head?
      head_branch="main"
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
