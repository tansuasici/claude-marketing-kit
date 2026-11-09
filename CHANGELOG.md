# Changelog

## [0.1.1](https://github.com/tansuasici/claude-marketing-kit/compare/v0.1.0...v0.1.1) (2026-11-09)


### Bug Fixes

* **release:** bump VERSION with each release and keep bytecode out of the package ([#41](https://github.com/tansuasici/claude-marketing-kit/issues/41)) ([566c0c4](https://github.com/tansuasici/claude-marketing-kit/commit/566c0c40de71754c01b641a65165c5c64526913b))
* **uninstall:** give a way out next to another kit that works ([#39](https://github.com/tansuasici/claude-marketing-kit/issues/39)) ([0770c08](https://github.com/tansuasici/claude-marketing-kit/commit/0770c08b8bd9bb4fb8e804e84ba09b36f1025d90))

## 0.1.0 (2026-11-09)


### Features

* add claim-scan hook ([#3](https://github.com/tansuasici/claude-marketing-kit/issues/3)) ([d7958fa](https://github.com/tansuasici/claude-marketing-kit/commit/d7958fa635d1f5127a1db0a82bdd401376a0f682))
* add slop-scan hook ([#2](https://github.com/tansuasici/claude-marketing-kit/issues/2)) ([244743c](https://github.com/tansuasici/claude-marketing-kit/commit/244743c4dd91642908e48b97581c1acd0e8c2aef))
* **agents:** add brand-voice-reviewer ([#28](https://github.com/tansuasici/claude-marketing-kit/issues/28)) ([603f185](https://github.com/tansuasici/claude-marketing-kit/commit/603f18597d80f60e4f6a738d1ef520fb7247f7fe))
* **agents:** add claim-checker ([#29](https://github.com/tansuasici/claude-marketing-kit/issues/29)) ([d759d86](https://github.com/tansuasici/claude-marketing-kit/commit/d759d86fc1a0a17d929ab9f8ae95dda8fc698973))
* **agents:** add skeptical-buyer ([#31](https://github.com/tansuasici/claude-marketing-kit/issues/31)) ([3eca77a](https://github.com/tansuasici/claude-marketing-kit/commit/3eca77a2effadfb993d8b636208a463de70402b5))
* **docs:** add Instagram Edits connector facts and rules ([#24](https://github.com/tansuasici/claude-marketing-kit/issues/24)) ([2700c60](https://github.com/tansuasici/claude-marketing-kit/commit/2700c60bb63d2c7cab348b39e5ab8ebcb5f99fd4))
* **docs:** add Remotion setup, licence facts and rules ([#25](https://github.com/tansuasici/claude-marketing-kit/issues/25)) ([8b3d345](https://github.com/tansuasici/claude-marketing-kit/commit/8b3d345f8218a2567e7415498e4f025d5d1d4ecb))
* **hooks:** block shell writes to copy files ([#33](https://github.com/tansuasici/claude-marketing-kit/issues/33)) ([20e73c5](https://github.com/tansuasici/claude-marketing-kit/commit/20e73c5a5355960104296b008f748c2403bb2cde))
* **hooks:** catch qualified "trusted by" lines, hide hook state from git ([#32](https://github.com/tansuasici/claude-marketing-kit/issues/32)) ([21a081b](https://github.com/tansuasici/claude-marketing-kit/commit/21a081b3cfce4c5a68ee1366a7440edaf5b88a63))
* **hooks:** channel-limits counts drafts against channel limits ([#4](https://github.com/tansuasici/claude-marketing-kit/issues/4)) ([c10cdb5](https://github.com/tansuasici/claude-marketing-kit/commit/c10cdb5fe2f3b5d6193bfbaa4f0a8a4a4e6267c8))
* **hooks:** publish-gate turns scheduler publish calls into a per-post prompt ([#5](https://github.com/tansuasici/claude-marketing-kit/issues/5)) ([8e921e6](https://github.com/tansuasici/claude-marketing-kit/commit/8e921e6cae380215f27c7a44bb7e3c202384b00b))
* **install:** refuse a folder that holds another Claude kit ([#35](https://github.com/tansuasici/claude-marketing-kit/issues/35)) ([623e45e](https://github.com/tansuasici/claude-marketing-kit/commit/623e45e5d761066def5897512a9e3c9db1e944a4))
* **map:** Changes table with a map version ([#8](https://github.com/tansuasici/claude-marketing-kit/issues/8)) ([eb112fe](https://github.com/tansuasici/claude-marketing-kit/commit/eb112fec491d7a8ff444662adade4cfd86d26696))
* **skills:** add brief, which fills MARKETING_MAP.md section by section ([#9](https://github.com/tansuasici/claude-marketing-kit/issues/9)) ([35efe13](https://github.com/tansuasici/claude-marketing-kit/commit/35efe13ceba537877966aa8e9918983349b09daa))
* **skills:** add campaign-report skill ([#21](https://github.com/tansuasici/claude-marketing-kit/issues/21)) ([240080e](https://github.com/tansuasici/claude-marketing-kit/commit/240080e1584cd983cf8ca4da2afc513c31726bf5))
* **skills:** add claim-audit, which checks a draft's claims against Evidence ([#10](https://github.com/tansuasici/claude-marketing-kit/issues/10)) ([d0eda39](https://github.com/tansuasici/claude-marketing-kit/commit/d0eda39d6eac99aa6237baf737646501c22c389b))
* **skills:** add competitor-brief skill ([#14](https://github.com/tansuasici/claude-marketing-kit/issues/14)) ([1fcd1bc](https://github.com/tansuasici/claude-marketing-kit/commit/1fcd1bc9ac80eda1075b0d5203a995d42011888c))
* **skills:** add email-sequence skill ([#17](https://github.com/tansuasici/claude-marketing-kit/issues/17)) ([e22fe0c](https://github.com/tansuasici/claude-marketing-kit/commit/e22fe0ce1d95821584c93d378524f795e8df97ac))
* **skills:** add landing-copy skill ([#12](https://github.com/tansuasici/claude-marketing-kit/issues/12)) ([41de530](https://github.com/tansuasici/claude-marketing-kit/commit/41de53000f00f851dded39e7c32c083dc66a7a24))
* **skills:** add launch-plan skill ([#18](https://github.com/tansuasici/claude-marketing-kit/issues/18)) ([516944f](https://github.com/tansuasici/claude-marketing-kit/commit/516944f09612d3bd4e62b9e1a6130ecd0b85451f))
* **skills:** add positioning skill ([#13](https://github.com/tansuasici/claude-marketing-kit/issues/13)) ([c4fb452](https://github.com/tansuasici/claude-marketing-kit/commit/c4fb4521a4aec792edf8b5e2d8b7ce0c5c78f666))
* **skills:** add repurpose skill ([#16](https://github.com/tansuasici/claude-marketing-kit/issues/16)) ([f99a971](https://github.com/tansuasici/claude-marketing-kit/commit/f99a97183cb25c750a74f3efa4edb9d352cb4523))
* **skills:** add seo-audit skill ([#20](https://github.com/tansuasici/claude-marketing-kit/issues/20)) ([b524374](https://github.com/tansuasici/claude-marketing-kit/commit/b5243743bd6734a7a4f5925891d3ad0c99931b6b))
* **skills:** add slop-audit skill ([#11](https://github.com/tansuasici/claude-marketing-kit/issues/11)) ([7a2ecdd](https://github.com/tansuasici/claude-marketing-kit/commit/7a2ecdde8a3051b84f413e7de1e18b55711acd68))
* **skills:** add social-post skill ([#15](https://github.com/tansuasici/claude-marketing-kit/issues/15)) ([4fce2d0](https://github.com/tansuasici/claude-marketing-kit/commit/4fce2d08279da50fd907be9e748f13395ddcf8aa))
* **skills:** add social-publish skill ([#22](https://github.com/tansuasici/claude-marketing-kit/issues/22)) ([aa9d4bd](https://github.com/tansuasici/claude-marketing-kit/commit/aa9d4bd54c71fbaddf48e32222225d28309f7f2f))
* **skills:** add video-produce, from one script to one local video file ([#26](https://github.com/tansuasici/claude-marketing-kit/issues/26)) ([93fedc6](https://github.com/tansuasici/claude-marketing-kit/commit/93fedc61617dd53e0f23ed97e902caf8473964b2))
* **skills:** add video-script skill ([#23](https://github.com/tansuasici/claude-marketing-kit/issues/23)) ([99a6135](https://github.com/tansuasici/claude-marketing-kit/commit/99a61352ec5686892a63af0651da88e6fd77f633))
* **skills:** add voice-of-customer skill ([#19](https://github.com/tansuasici/claude-marketing-kit/issues/19)) ([03f0db2](https://github.com/tansuasici/claude-marketing-kit/commit/03f0db290b4764036a0d9647565e67d78924940a))
* **skills:** bridge a local video to social-publish through a hosted link ([#27](https://github.com/tansuasici/claude-marketing-kit/issues/27)) ([5e337ae](https://github.com/tansuasici/claude-marketing-kit/commit/5e337ae10ed2b9ea086865bfc2672cd6522741df))

## Changelog

All notable changes to Claude Marketing Kit will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
