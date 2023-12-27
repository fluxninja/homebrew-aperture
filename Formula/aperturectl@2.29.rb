class AperturectlAT229 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.29.1-rc.1.tar.gz"
  sha256 "80110729fa4cf02e9d1d26f210a3c6058523f6f6610acc4e77aa5547fd898251"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl@2.29-2.29.1-rc.1"
    sha256 cellar: :any_skip_relocation, monterey:     "eea7928caa699a3ba151055f11acb7e28bcb1f4f286845b1c253ab778da59679"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "384b44231c644a59084d48f62abe1c916a4eef093d77d6649d6a30063cfffb66"
  end

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    git_branch="stable/v2.29.x"
    git_commit_hash="692842c9f83cb10897861052baf1e9f91e9069b5"

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
