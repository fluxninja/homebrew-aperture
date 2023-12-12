class Aperturectl < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.27.1.tar.gz"
  sha256 "b842ddb80be289ba38d6883cd1bd5b40b83ef458d95f1803a158a2fbe5bb028e"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl-2.27.0"
    sha256 cellar: :any_skip_relocation, monterey:     "8c0c2a7fe8552f2f8e2f206b6de7b795d86d63f78c74ba01d9db4d50528fba4e"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "161ab38de46b131ecc38eac2dbc118e2a2a1ab4d037463c883186857251aa2da"
  end

  depends_on "go" => :build

  def install
    git_branch="stable/v2.27.x"
    git_commit_hash="81abaa25d93124ffb8bb80396d78336b9202722c"

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
