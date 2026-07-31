# Patches to things this repo does not own

`km` lives at `~/.km/setup.sh` and is **not** under version control here. It
reinstalls itself from `curl -fsSL .../KM/main/setup.sh | bash`, which
overwrites the file. Any fix applied in place is therefore temporary and will
vanish silently on the next KM update — the patch below exists so that is
recoverable rather than rediscovered.

```sh
patch -p0 ~/.km/setup.sh < patches/km-prepull.patch     # reapply
```

## km-prepull.patch — two defects, both measured on live boxes

**1. The progress meter watched a directory the downloader never wrote to.**
It read `~/.cache/{llama.cpp,huggingface}`, but vast.ai images export
`HF_HOME=/workspace/.hf_home`. On those boxes it printed `weights 0.0GB/18.0GB
0%` for twenty-five minutes while gigabytes landed elsewhere. A display that
asserts something the box disagrees with is the same defect class as a check
grading against a deleted directory — see the fourth law in the README.

**2. Weights arrived single-stream.** llama.cpp fetches with one connection and
Hugging Face throttles per connection, not per client. Measured on two boxes on
2026-07-31, same wire, same minute:

```
 1 connection    ~5 MB/s     18GB in ~50 minutes
 8 connections  ~48 MB/s
16 connections  ~67-77 MB/s  18GB in ~5 minutes
```

Forty-five minutes of paid idle on every cold box. `_prepull_gguf` now fetches
with 16 parallel range requests, verifies the assembly against Hugging Face's
own `x-linked-etag` — which for an LFS object *is* the sha256 of the content —
and serves the local file with `-m`. On any failure it returns nonzero and the
caller falls back to `-hf`: slow, but it has always worked, and a fast path
that can strand you is not an upgrade. Set `KM_PREPULL=0` to disable.

**A trap inside the fix, recorded because it cost a real download:** the etag
header must have its NAME stripped before hex characters are kept. `tr -dc
'0-9a-f'` over the whole line takes `edea` out of `x-linkEDEATag` and prepends
it to the digest, so a correct file fails verification.
