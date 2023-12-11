class AperturectlAT227 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.27.0.tar.gz"
  sha256 "a30cb63e0254b3ecbef60fbb0dc1a37f4b9c654a32809fdd55921fa23baf59e5"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl@2.27-2.27.0"
    sha256 cellar: :any_skip_relocation, monterey:     "67cf9ffa2826ecba89d4a82d1ed3a15e975d3005723009d084cb04b396ad9ff4"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "b3af940dbe394c888d80f37d9612b2bff374f9d4ce4aba7e957cb3bfa1a64ddb"
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
