class AperturectlAT230 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.30.1-rc.1.tar.gz"
  sha256 "2d8bd6ef3d4a85d2dadcbce8be42dec562aceac3854c392be3ca40117d9901e3"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl@2.30-2.30.0"
    sha256 cellar: :any_skip_relocation, monterey:     "b06854612091a3aee0620e34d3457b37b98acd6829790af4d22956b2e8d6c6b7"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "eaa3f9bd95a7445773fc54ad4a0db731da13bd4aa98c3176e034fa612689c980"
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
