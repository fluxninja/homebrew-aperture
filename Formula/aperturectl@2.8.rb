class AperturectlAT28 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/v2.8.2-rc.1.tar.gz"
  sha256 "83c63b77db4641d426010987692a87836a5ec15c5d21c77910badc0853677a64"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "stable/v2.8.x"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl@2.8-2.8.1-rc.1"
    sha256 cellar: :any_skip_relocation, monterey:     "f809610c442c39992f3fe6a73ad3af69f58ee2f6ae457c912f6d9c44bbee31da"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "e1f9dd5e1fb0ed7b953105915f51532a92fb6c1e51156e5f3724ef73faf51ccb"
  end

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    git_branch="stable/v2.8.x"
    git_commit_hash="e897c94e8efd007a00189774c09b788b5f27ad3e"

    require "open3"
    if build.head?
      head_branch="stable/v2.8.x"
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
