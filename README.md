# terraform just for redirect
## what

あるサイトへのあらゆるリクエストを特定のURLにリダイレクトするためのCF+S3構築用terraform。

- コンセプトは以下
    - 既存terraformのtfstateとは独立して利用可能
    - 環境複製時も極力 variables.tf のみの編集で完結

## Require

- direnv
- docker/docker-compose

## Files

```bash
tree
.
├── README.md
├── aws.tf                     # 構築時pluginのversion指定
├── cfs3_just_for_redirect.tf  # 本体。CloudFront及びS3のresource
├── data_acm.tf                # CloudFront用のACM証明書データ取得
├── docker-compose.yaml        # terraformコマンドをdocker-composeで動かすために
└── variables.tf               # 案件固有の値はここで管理
```

SSL証明書を別途ACMで取得していることを前提としたつくり。

## Usage
1. set env
(direnv使用が前提) 以下どちらかの環境変数を設定(参照: .envrc_example)

- `AWS_PROFILE`
- `AWS_ACCESS_KEY_ID` 及び `AWS_SECRET_ACCESS_KEY`

```bash
direnv edit .
```

2. set variables
リダイレクト元/先のドメインとS3バケット名を指定

```bash
vim variables.tf
```

3. apply
terraformのversion指定するため、hashicorp公式提供のdockerイメージを利用してコマンド実行

```bash
# plugin導入
docker-compose run --rm terraform init
# 確認
docker-compose run --rm terraform plan
# 構築
docker-compose run --rm terraform apply
```

4. edit DNS
DNS管理をどこで行なっているかを踏まえ、リダイレクト元ドメイン→cloudfrontへのCNAMEレコード登録を実施
(Route53の場合はAlias)

5. check

設定後、URL閲覧確認できれば完了。

## Tips

variables編集以外でカスタマイズが必要なケースについて記載

### 特定のパスへのリダイレクト

`https://example.net/hoge/` にリダイレクトさせたい場合、
ReplaceKeyWithタグに `hoge/` を設定する。

```title:resource.aws_s3_bucket.just_for_redirect_01
    routing_rules = <<EOF
[{
  "Redirect": {
    "Protocol":"https",
    "HostName":"${var.domain["just_for_redirect_01_to"]}"
    "ReplaceKeyWith":"hoge/"      # ここを追加
    }
}]
EOF
```

- その他、各タグの詳細についての公式ドキュメントは以下
    - https://docs.aws.amazon.com/ja_jp/AmazonS3/latest/dev/how-to-page-redirect.html

### 同アカウント内で複数のリダイレクト環境を構築

resouce/dataの名前とvariablesの共通プレフィックスを `just_for_redirect_01` で統一している。
同一のtfstate管理で複数構築する場合は各要素の複製+ナンバリングでok
