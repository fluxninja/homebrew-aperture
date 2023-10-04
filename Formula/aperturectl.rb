class Aperturectl < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/v2.18.2.tar.gz"
  sha256 "deba45b721dfa0e9add6c862f2dbbc54041269b6bec0268715666f30ddc3058b"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl-2.18.2"
    sha256 cellar: :any_skip_relocation, monterey:     "4f32445ec2e57d760ef88977c9bbc5bc57b00a43e139d3d970766d8eb2cba08a"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "aa1c1c2d3d50f21dd336af7e342e6d788a133a19d5ff3eb45462702099eae3e9"
  end

  depends_on "go" => :build

  def install
    git_branch="stable/v2.18.x"
    git_commit_hash="11b2839aa1100b14be98e377caf8f0895891cfea"

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
