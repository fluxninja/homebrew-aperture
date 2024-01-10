class AperturectlAT230 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.30.1.tar.gz"
  sha256 "e6593b2d4588030267ddbeebfd8903344824594d28a7057ae62ba610e824f11a"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl@2.30-2.30.1"
    sha256 cellar: :any_skip_relocation, monterey:     "985196bde7f66546a19d27690d68c0065e6b481a3934e757ff38ea032f16a9b1"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "0d5d5d559410294816c5908ef7f08f94d829e8257ceac19f213ae12a3b1d13d3"
  end

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    git_branch="stable/v2.30.x"
    git_commit_hash="9159bc64858bf3e4e086c7ab75144dc52a4d362a"

    require "open3"
    if build.head?
      head_branch="stable/v2.30.x"
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
