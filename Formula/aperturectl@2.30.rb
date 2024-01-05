class AperturectlAT230 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.30.0.tar.gz"
  sha256 "b89d65b6a87cee2e40f9497dfeb47c694f434c5efdc790f2989312d6dd580634"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl@2.30-2.30.0-rc.1"
    sha256 cellar: :any_skip_relocation, monterey:     "971c0f9df08c0cd5f9b0419e559fbad694baf146ffb2ed9385015bac9c2f2689"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "9c644fc624d34bc83c955c99f526d9e7438cd1016bad20999ad53ecdbc828f3c"
  end

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    git_branch="stable/v2.30.x"
    git_commit_hash="49006a3c2419a636ecddec86c7eb3012b2a939b0"

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
