locals {
  storage_shares = { "dalishare" = var.storage.quotas.dali, "dllsshare" = var.storage.quotas.dll, "sashashare" = var.storage.quotas.sasha,
  "datashare" = var.storage.quotas.data, "lzshare" = var.storage.quotas.lz }
}
