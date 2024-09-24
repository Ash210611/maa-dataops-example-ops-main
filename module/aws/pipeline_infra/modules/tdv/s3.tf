locals {
  s3_prefix            = var.type_map.s3-prefix != null ? "/${var.type_map.s3-prefix}" : ""
  table_files_path     = "${var.repo_path}/${var.type_map.name}/${var.type_map.path-to-tables}"
  view_files_path      = "${var.repo_path}/${var.type_map.name}/${var.type_map.path-to-views}"
  changelog_files_path = "${var.repo_path}/${var.type_map.name}/${var.type_map.path-to-changelog}"
  config_files_path    = "${var.repo_path}/${var.type_map.name}/${var.type_map.path-to-config}"
  destination_folder   = "${var.solution_repo}${local.s3_prefix}/${var.type_map.name}/${var.branch}"
  dag_path = "${var.repo_path}/${var.type_map.name}/dags"
  stored_proc_path = "${var.repo_path}/${var.type_map.name}/stored_procs"
  available_tdv_changelog_map = lookup(var.tdv_environments, var.env)
  tdv_changelog_map = {
    for tdv in local.available_tdv_changelog_map :
    tdv => fileset("${local.changelog_files_path}", "${tdv}.changelog.xml")
  }
  changelog_files = distinct(flatten(values(local.tdv_changelog_map)))

  tdv_config_map = {
    for tdv in local.available_tdv_changelog_map :
    tdv => fileset("${local.config_files_path}", "${upper(tdv)}/*")
  }

  config_files = distinct(flatten(values(local.tdv_config_map)))
}

resource "aws_s3_object" "custom_dag" {
  for_each = fileset(local.dag_path, "*")

  bucket = var.dest_bucket
  key    = "dags/${local.destination_folder}/${each.value}"
  source = "${local.dag_path}/${each.value}"

  source_hash = filemd5("${local.dag_path}/${each.value}")
}

resource "aws_s3_object" "table_files" {
  for_each = fileset(local.table_files_path, "*")

  bucket = var.dest_bucket
  key    = "${local.destination_folder}/${var.type_map.path-to-tables}/${each.value}"
  source = "${local.table_files_path}/${each.value}"

  source_hash = filemd5("${local.table_files_path}/${each.value}")
}

resource "aws_s3_object" "view_files" {
  for_each = fileset(local.view_files_path, "*")

  bucket = var.dest_bucket
  key    = "${local.destination_folder}/${var.type_map.path-to-views}/${each.value}"
  source = "${local.view_files_path}/${each.value}"

  source_hash = filemd5("${local.view_files_path}/${each.value}")
}

resource "aws_s3_object" "changelog" {
  for_each = toset(nonsensitive(local.changelog_files))

  bucket = var.dest_bucket
  key    = "${local.destination_folder}/${each.value}"
  source = "${local.changelog_files_path}/${each.value}"
  source_hash = filemd5("${local.changelog_files_path}/${each.value}")
}

resource "aws_s3_object" "config_files" {
  for_each = toset(nonsensitive(local.config_files))

  bucket = var.dest_bucket
  key    = "${local.destination_folder}/${each.value}"
  source = "${local.config_files_path}/${each.value}"
  source_hash = filemd5("${local.config_files_path}/${each.value}")
}