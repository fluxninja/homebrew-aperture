class AperturectlAT225 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.25.2-rc.1.tar.gz"
  sha256 "4a3342a408d5f60c77806dc8917669a0ccd6337b784c9fe8f896d88387ea4ab2"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl@2.25-2.25.1"
    sha256 cellar: :any_skip_relocation, monterey:     "a9111c768f8c0cc348c6121f2aa612e76aea439a625c574c35ee7ec103695e31"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "b6074bde359228436b5a9c526423489ac623ba7fa557b831cef6abc2a5690888"
  end

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    git_branch="stable/v2.25.x"
    git_commit_hash="cf6cee46be8d0800f5c539df07953b0757cfccfb"

    require "open3"
    if build.head?
      head_branch="stable/v2.25.x"
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
