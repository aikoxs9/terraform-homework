provider "aws" {
  region = "us-east-1" 
}

resource "aws_iam_user" "blackpink" {
  for_each = toset(["jenny", "rose", "lisa", "jisoo"])
  name     = each.key
}

resource "aws_iam_user" "twice" {
  for_each = toset(["jihyo", "sana", "momo", "dahyun"])
  name     = each.key
}

resource "aws_iam_group" "blackpink" {
  name = "blackpink"
}

resource "aws_iam_group" "twice" {
  name = "twice"
}

resource "aws_iam_group_membership" "blackpink_members" {
  name  = "blackpink-membership"
  users = [for u in aws_iam_user.blackpink : u.name]
  group = aws_iam_group.blackpink.name
}

resource "aws_iam_group_membership" "twice_members" {
  name  = "twice-membership"
  users = [for u in aws_iam_user.twice : u.name]
  group = aws_iam_group.twice.name
}


resource "aws_iam_user" "miyeon" {
  name = "miyeon"
}

resource "aws_iam_user" "mina" {
  name = "mina"
}

resource "aws_iam_group_membership" "blackpink_extra" {
  name  = "blackpink-extra-membership"
  users = [aws_iam_user.miyeon.name]
  group = aws_iam_group.blackpink.name
}

resource "aws_iam_group_membership" "twice_extra" {
  name  = "twice-extra-membership"
  users = [aws_iam_user.mina.name]
  group = aws_iam_group.twice.name
}
