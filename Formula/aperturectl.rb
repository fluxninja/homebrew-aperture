class Aperturectl < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.23.0.tar.gz"
  sha256 "2f94f9e57d52cbe89164ddf97fc840f2d00efab2c0c11ec81f8015b69380b51b"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl-2.22.1"
    sha256 cellar: :any_skip_relocation, monterey:     "658194d6834107fa3598429a2dc2fcd588c3f88862865d17897c78d7f2b7bc7f"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "8a592077ad246fc6859932b38970cd2c22cc63e476a6735d716128826b6958f9"
  end

  depends_on "go" => :build

  def install
    git_branch="stable/v2.23.x"
    git_commit_hash="20a27bf0078ec531ae80d17a74ee1d7d84e2c36e"

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
