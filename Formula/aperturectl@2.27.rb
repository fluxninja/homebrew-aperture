class AperturectlAT227 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.27.0-rc.1.tar.gz"
  sha256 "d7f9619c26e4abfbadf5f4803d815ba67a259a5a452c7685cd38ed7be2f91ce1"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl@2.27-2.27.0-rc.1"
    sha256 cellar: :any_skip_relocation, monterey:     "2429e89cfc52bebae6cda13af7dbaa4e46922516f79f1edd4880fd9a28a21412"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "b9613d05bd8ea05d929350d8a389ede9251eb1241c8970f2260f66d87ce9f3f7"
  end

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    git_branch="stable/v2.27.x"
    git_commit_hash="a1fa9d26ddbf802d11a9361027c5491c24ba665e"

    require "open3"
    if build.head?
      head_branch="stable/v2.27.x"
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
