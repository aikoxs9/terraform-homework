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


resource "aws_iam_user_group_membership" "blackpink" {
  user = aws_iam_user.blackpink[each.key].name
  groups = [aws_iam_group.blackpink.name]
  for_each = aws_iam_user.blackpink
}

resource "aws_iam_user_group_membership" "twice" {
  user = aws_iam_user.twice[each.key].name
  groups = [aws_iam_group.twice.name]
  for_each = aws_iam_user.twice
}


resource "aws_iam_user" "miyeon" {
  name = "miyeon"
}

resource "aws_iam_user" "mina" {
  name = "mina"
}


resource "aws_iam_user_group_membership" "miyeon_group" {
  user   = aws_iam_user.miyeon.name
  groups = [aws_iam_group.blackpink.name]
}

resource "aws_iam_user_group_membership" "mina_group" {
  user   = aws_iam_user.mina.name
  groups = [aws_iam_group.twice.name]
}
