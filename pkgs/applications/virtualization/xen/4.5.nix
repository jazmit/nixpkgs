{ callPackage, fetchurl, fetchpatch, fetchgit, ... } @ args:

let
  # Xen 4.5.5
  #
  # Patching XEN? Check the XSAs and try applying all the ones we
  # don't have yet.
  #
  # XSAs at: https://xenbits.xen.org/xsa/
  xenConfig = rec {
    version = "4.5.5";

    xsaPatch = { name , sha256 }: (fetchpatch {
      url = "https://xenbits.xen.org/xsa/xsa${name}.patch";
      inherit sha256;
    });

    name = "xen-${version}";

    src = fetchurl {
      url = "http://bits.xensource.com/oss-xen/release/${version}/${name}.tar.gz";
      sha256 = "1y74ms4yc3znf8jc3fgyq94va2y0pf7jh8m9pfqnpgklywqnw8g2";
    };

    # Sources needed to build the xen tools and tools/firmware.
    firmwareGits =
      [
        { git = { name = "seabios";
                  url = https://xenbits.xen.org/git-http/seabios.git;
                  rev = "rel-1.7.5";
                  sha256 = "0jk54ybhmw97pzyhpm6jr2x99f702kbn0ipxv5qxcbynflgdazyb";
                };
          patches = [ ./0000-qemu-seabios-enable-ATA_DMA.patch ];
        }
      ];

    toolsGits =
      [
        { git = { name = "qemu-xen";
                  url = https://xenbits.xen.org/git-http/qemu-xen.git;
                  rev = "refs/tags/qemu-xen-${version}";
                  sha256 = "014s755slmsc7xzy7qhk9i3kbjr2grxb5yznjp71dl6xxfvnday2";
                };
          patches = [
            (xsaPatch {
              name = "197-4.5-qemuu";
              sha256 = "09gp980qdlfpfmxy0nk7ncyaa024jnrpzx9gpq2kah21xygy5myx";
            })
            (xsaPatch {
              name = "208-qemuu-4.7";
              sha256 = "0z9b1whr8rp2riwq7wndzcnd7vw1ckwx0vbk098k2pcflrzppgrb";
            })
            (xsaPatch {
              name = "209-qemuu";
              sha256 = "05df4165by6pzxrnizkw86n2f77k9i1g4fqqpws81ycb9ng4jzin";
            })
            (xsaPatch {
              name = "211-qemuu-4.6";
              sha256 = "1g090xs8ca8676vyi78b99z5yjdliw6mxkr521b8kimhf8crx4yg";
            })
          ];
        }
        { git = { name = "qemu-xen-traditional";
                  url = https://xenbits.xen.org/git-http/qemu-xen-traditional.git;
                  # rev = "28c21388c2a32259cff37fc578684f994dca8c9f";
                  rev = "refs/tags/xen-${version}";
                  sha256 = "0n0ycxlf1wgdjkdl8l2w1i0zzssk55dfv67x8i6b2ima01r0k93r";
                };
          patches = [
            (xsaPatch {
              name = "197-4.5-qemut";
              sha256 = "17l7npw00gyhqzzaqamwm9cawfvzm90zh6jjyy95dmqbh7smvy79";
            })
            (xsaPatch {
              name = "199-trad";
              sha256 = "0dfw6ciycw9a9s97sbnilnzhipnzmdm9f7xcfngdjfic8cqdcv42";
            })
            (xsaPatch {
              name = "208-qemut";
              sha256 = "0960vhchixp60j9h2lawgbgzf6mpcdk440kblk25a37bd6172l54";
            })
            (xsaPatch {
              name = "209-qemut";
              sha256 = "1hq8ghfzw6c47pb5vf9ngxwgs8slhbbw6cq7gk0nam44rwvz743r";
            })
            (xsaPatch {
              name = "211-qemut-4.5";
              sha256 = "1z3phabvqmxv4b5923fx63hwdg4v1fnl15zbl88873ybqn0hp50f";
            })
          ];
        }
        { git = { name = "xen-libhvm";
                  url = https://github.com/ts468/xen-libhvm;
                  rev = "442dcc4f6f4e374a51e4613532468bd6b48bdf63";
                  sha256 = "9ba97c39a00a54c154785716aa06691d312c99be498ebbc00dc3769968178ba8";
                };
          description = ''
            Helper library for reading ACPI and SMBIOS firmware values
            from the host system for use with the HVM guest firmware
            pass-through feature in Xen.
            '';
          #license = licenses.bsd2;
        }
      ];

      xenPatches = [ ./0001-libxl-Spice-image-compression-setting-support-for-up.patch
                     ./0002-libxl-Spice-streaming-video-setting-support-for-upst.patch
                     ./0003-Add-qxl-vga-interface-support-for-upstream-qem.patch
                     (xsaPatch {
                       name = "190-4.5";
                       sha256 = "0f8pw38kkxky89ny3ic5h26v9zsjj9id89lygx896zc3w1klafqm";
                     })
                     (xsaPatch {
                       name = "191-4.6";
                       sha256 = "1wl1ndli8rflmc44pkp8cw4642gi8z7j7gipac8mmlavmn3wdqhg";
                     })
                     (xsaPatch {
                       name = "192-4.5";
                       sha256 = "0m8cv0xqvx5pdk7fcmaw2vv43xhl62plyx33xqj48y66x5z9lxpm";
                     })
                     (xsaPatch {
                       name = "193-4.5";
                       sha256 = "0k9mykhrpm4rbjkhv067f6s05lqmgnldcyb3vi8cl0ndlyh66lvr";
                     })
                     (xsaPatch {
                       name = "195";
                       sha256 = "0m0g953qnjy2knd9qnkdagpvkkgjbk3ydgajia6kzs499dyqpdl7";
                     })
                     (xsaPatch {
                       name = "196-0001-x86-emul-Correct-the-IDT-entry-calculation-in-inject";
                       sha256 = "0z53nzrjvc745y26z1qc8jlg3blxp7brawvji1hx3s74n346ssl6";
                     })
                     (xsaPatch {
                       name = "196-0002-x86-svm-Fix-injection-of-software-interrupts";
                       sha256 = "11cqvr5jn2s92wsshpilx9qnfczrd9hnyb5aim6qwmz3fq3hrrkz";
                     })
                     (xsaPatch {
                       name = "198";
                       sha256 = "0d1nndn4p520c9xa87ixnyks3mrvzcri7c702d6mm22m8ansx6d9";
                     })
                     (xsaPatch {
                       name = "200-4.6";
                       sha256 = "0k918ja83470iz5k4vqi15293zjvz2dipdhgc9sy9rrhg4mqncl7";
                     })
                     (xsaPatch {
                       name = "202-4.6";
                       sha256 = "0nnznkrvfbbc8z64dr9wvbdijd4qbpc0wz2j5vpmx6b32sm7932f";
                     })
                     (xsaPatch {
                       name = "204-4.5";
                       sha256 = "083z9pbdz3f532fnzg7n2d5wzv6rmqc0f4mvc3mnmkd0rzqw8vcp";
                     })
                     (xsaPatch {
                       name = "206-4.5/0001-xenstored-apply-a-write-transaction-rate-limit";
                       sha256 = "07vsm8mlbxh2s01ny2xywnm1bqhhxas1az31fzwb6f1g14vkzwm4";
                     })
                     (xsaPatch {
                       name = "206-4.5/0002-xenstored-Log-when-the-write-transaction-rate-limit-";
                       sha256 = "17pnvxjmhny22abwwivacfig4vfsy5bqlki07z236whc2y7yzbsx";
                     })
                     (xsaPatch {
                       name = "206-4.5/0003-oxenstored-refactor-putting-response-on-wire";
                       sha256 = "0xf566yicnisliy82cydb2s9k27l3bxc43qgmv6yr2ir3ixxlw5s";
                     })
                     (xsaPatch {
                       name = "206-4.5/0004-oxenstored-remove-some-unused-parameters";
                       sha256 = "16cqx9i0w4w3x06qqdk9rbw4z96yhm0kbc32j40spfgxl82d1zlk";
                     })
                     (xsaPatch {
                       name = "206-4.5/0005-oxenstored-refactor-request-processing";
                       sha256 = "1g2hzlv7w03sqnifbzda85mwlz3bw37rk80l248180sv3k7k6bgv";
                     })
                     (xsaPatch {
                       name = "206-4.5/0006-oxenstored-keep-track-of-each-transaction-s-operatio";
                       sha256 = "0n65yfxvpfd4cz95dpbwqj3nablyzq5g7a0klvi2y9zybhch9cmg";
                     })
                     (xsaPatch {
                       name = "206-4.5/0007-oxenstored-move-functions-that-process-simple-operat";
                       sha256 = "0qllvbc9rnj7jhhlslxxs35gvphvih0ywz52jszj4irm23ka5vnz";
                     })
                     (xsaPatch {
                       name = "206-4.5/0008-oxenstored-replay-transaction-upon-conflict";
                       sha256 = "0lixkxjfzciy9l0f980cmkr8mcsx14c289kg0mn5w1cscg0hb46g";
                     })
                     (xsaPatch {
                       name = "206-4.5/0009-oxenstored-log-request-and-response-during-transacti";
                       sha256 = "09ph8ddcx0k7rndd6hx6kszxh3fhxnvdjsq13p97n996xrpl1x7b";
                     })
                     (xsaPatch {
                       name = "206-4.5/0010-oxenstored-allow-compilation-prior-to-OCaml-3.12.0";
                       sha256 = "1y0m7sqdz89z2vs4dfr45cyvxxas323rxar0xdvvvivgkgxawvxj";
                     })
                     (xsaPatch {
                       name = "206-4.5/0011-oxenstored-comments-explaining-some-variables";
                       sha256 = "1d3n0y9syya4kaavrvqn01d3wsn85gmw7qrbylkclznqgkwdsr2p";
                     })
                     (xsaPatch {
                       name = "206-4.5/0012-oxenstored-handling-of-domain-conflict-credit";
                       sha256 = "12zgid5y9vrhhpk2syxp0x01lzzr6447fa76n6rjmzi1xgdzpaf8";
                     })
                     (xsaPatch {
                       name = "206-4.5/0013-oxenstored-ignore-domains-with-no-conflict-credit";
                       sha256 = "0v3g9pm60w6qi360hdqjcw838s0qcyywz9qpl8gzmhrg7a35avxl";
                     })
                     (xsaPatch {
                       name = "206-4.5/0014-oxenstored-add-transaction-info-relevant-to-history-";
                       sha256 = "0vv3w0h5xh554i9v2vbc8gzm8wabjf2vzya3dyv5yzvly6ygv0sb";
                     })
                     (xsaPatch {
                       name = "206-4.5/0015-oxenstored-support-commit-history-tracking";
                       sha256 = "1iv2vy29g437vj73x9p33rdcr5ln2q0kx1b3pgxq202ghbc1x1zj";
                     })
                     (xsaPatch {
                       name = "206-4.5/0016-oxenstored-only-record-operations-with-side-effects-";
                       sha256 = "1cjkw5ganbg6lq78qsg0igjqvbgph3j349faxgk1p5d6nr492zzy";
                     })
                     (xsaPatch {
                       name = "206-4.5/0017-oxenstored-discard-old-commit-history-on-txn-end";
                       sha256 = "0lm15lq77403qqwpwcqvxlzgirp6ffh301any9g401hs98f9y4ps";
                     })
                     (xsaPatch {
                       name = "206-4.5/0018-oxenstored-track-commit-history";
                       sha256 = "1jh92p6vjhkm3bn5vz260npvsjji63g2imsxflxs4f3r69sz1nkd";
                     })
                     (xsaPatch {
                       name = "206-4.5/0019-oxenstored-blame-the-connection-that-caused-a-transa";
                       sha256 = "17k264pk0fvsamj85578msgpx97mw63nmj0j9v5hbj4bgfazvj4h";
                     })
                     (xsaPatch {
                       name = "206-4.5/0020-oxenstored-allow-self-conflicts";
                       sha256 = "15z3rd49q0pa72si0s8wjsy2zvbm613d0hjswp4ikc6nzsnsh4qy";
                     })
                     (xsaPatch {
                       name = "206-4.5/0021-oxenstored-do-not-commit-read-only-transactions";
                       sha256 = "04wpzazhv90lg3228z5i6vnh1z4lzd08z0d0fvc4br6pkd0w4va8";
                     })
                     (xsaPatch {
                       name = "206-4.5/0022-oxenstored-don-t-wake-to-issue-no-conflict-credit";
                       sha256 = "1shbrn0w68rlywcc633zcgykfccck1a77igmg8ydzwjsbwxsmsjy";
                     })
                     (xsaPatch {
                       name = "206-4.5/0023-oxenstored-transaction-conflicts-improve-logging";
                       sha256 = "1086y268yh8047k1vxnxs2nhp6izp7lfmq01f1gq5n7jiy1sxcq7";
                     })
                     (xsaPatch {
                       name = "206-4.5/0024-oxenstored-trim-history-in-the-frequent_ops-function";
                       sha256 = "014zs6i4gzrimn814k5i7gz66vbb0adkzr2qyai7i4fxc9h9r7w8";
                     })
                     (xsaPatch {
                       name = "207";
                       sha256 = "0wdlhijmw9mdj6a82pyw1rwwiz605dwzjc392zr3fpb2jklrvibc";
                     })
                     (xsaPatch {
                       name = "212";
                       sha256 = "1ggjbbym5irq534a3zc86md9jg8imlpc9wx8xsadb9akgjrr1r8d";
                     })
                     (xsaPatch {
                       name = "213-4.5";
                       sha256 = "1vnqf89ydacr5bq3d6z2r33xb2sn5vsd934rncyc28ybc9rvj6wm";
                     })
                     (xsaPatch {
                       name = "214";
                       sha256 = "0qapzx63z0yl84phnpnglpkxp6b9sy1y7cilhwjhxyigpfnm2rrk";
                     })
                     (xsaPatch {
                       name = "215";
                       sha256 = "0sv8ccc5xp09f1w1gj5a9n3mlsdsh96sdb1n560vh31f4kkd61xs";
                     })
                   ];
  };

in callPackage ./generic.nix (args // { xenConfig=xenConfig; })
