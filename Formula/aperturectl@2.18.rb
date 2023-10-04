class AperturectlAT218 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/v2.18.2.tar.gz"
  sha256 "deba45b721dfa0e9add6c862f2dbbc54041269b6bec0268715666f30ddc3058b"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "stable/v2.18.x"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl@2.18-2.18.2"
    sha256 cellar: :any_skip_relocation, monterey:     "1bfcab27d9d40ae0cc4be30d888955592f5be0a2cedb4ebeb52580542279fe7f"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "1d6920e8a5787171224fb9c2cb179d1cec4f0fd4b31c98bdaf922cc48b9cec2e"
  end

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    git_branch="stable/v2.18.x"
    git_commit_hash="11b2839aa1100b14be98e377caf8f0895891cfea"

    require "open3"
    if build.head?
      head_branch="stable/v2.18.x"
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
