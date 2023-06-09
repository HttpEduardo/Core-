class Libadwaita < Formula
  desc "Building blocks for modern adaptive GNOME applications"
  homepage "https://gnome.pages.gitlab.gnome.org/libadwaita/"
  url "https://download.gnome.org/sources/libadwaita/1.2/libadwaita-1.2.3.tar.xz"
  sha256 "c2758122bc09eee02b612976365a4532b16d7ee482b75f57efc9a9de52161f05"
  license "LGPL-2.1-or-later"

  # libadwaita doesn't use GNOME's "even-numbered minor is stable" version
  # scheme. This regex is the same as the one generated by the `Gnome` strategy
  # but it's necessary to avoid the related version scheme logic.
  livecheck do
    url :stable
    regex(/libadwaita-(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    sha256 arm64_ventura:  "0a4dea9e3ea8b5752893debf34804766051451f0052616349273ff523b4167f0"
    sha256 arm64_monterey: "1876dafd907cfbbf6b163fe7a3042c1d7b11685bb0de3255f787862b06578fab"
    sha256 arm64_big_sur:  "7089ab6b3681a24518eb870bc59175c2813b63c465de18b479a1108dd73e3840"
    sha256 ventura:        "aa255a31c6d41dda91e997777851f1abe305e207648139d45bed67091f195f30"
    sha256 monterey:       "5c21a1c3a2b0c24d64e15b1c7a520f7ecbb4c62e9958e1cd10fbf2a8d3032cfa"
    sha256 big_sur:        "17c343ce6354270e437412eb2b2beda37d34ba609bd9e06ef53860a657231ebb"
    sha256 x86_64_linux:   "f6a475fc0d11957ce7e2ace16d4d055e6d4a98971475ed90efd1953f680597df"
  end

  depends_on "gettext" => :build
  depends_on "gobject-introspection" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => [:build, :test]
  depends_on "vala" => :build
  depends_on "gtk4"

  def install
    system "meson", "setup", "build", "-Dtests=false", *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    # Remove when `jpeg-turbo` is no longer keg-only.
    ENV.prepend_path "PKG_CONFIG_PATH", Formula["jpeg-turbo"].opt_lib/"pkgconfig"

    (testpath/"test.c").write <<~EOS
      #include <adwaita.h>

      int main(int argc, char *argv[]) {
        g_autoptr (AdwApplication) app = NULL;
        app = adw_application_new ("org.example.Hello", G_APPLICATION_FLAGS_NONE);
        return g_application_run (G_APPLICATION (app), argc, argv);
      }
    EOS
    flags = shell_output("#{Formula["pkg-config"].opt_bin}/pkg-config --cflags --libs libadwaita-1").strip.split
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test", "--help"

    # include a version check for the pkg-config files
    assert_match version.to_s, (lib/"pkgconfig/libadwaita-1.pc").read
  end
end
