class Aperturectl < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.29.3.tar.gz"
  sha256 "7faada9ba9e8f0b71d9088b343cbca520bfe8756b53d54ca7728ff28ebf264bd"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl-2.29.2"
    sha256 cellar: :any_skip_relocation, monterey:     "5d89f0e28b44927e5baddd4a3d5eadc63831459e12eef224abdb497a587fc131"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "5513e11df7c49c15e2d416c6c648914680025f9be2beb92f2993e1827b26aa62"
  end

  depends_on "go" => :build

  def install
    git_branch="stable/v2.29.x"
    git_commit_hash="b4abafbc9cb05169811b6fa060f65c037997a19b"

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
