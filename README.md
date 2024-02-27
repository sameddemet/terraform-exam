# examen-s13-terraform

Le but de cet examen est de construire via Terraform toutes les ressources associées à la publication d'un fichier index.html.

Il faut déployer avec Terraform les ressources suivantes :

- un volume S3, pour y stocker votre fichier index.html
- une distribution Cloudfront, avec comme origin le volume S3
- un pointage DNS Route53 pour pointer une entrée de devops.oclock.school vers le site
- un certificat SSL déployé sur la distribution Cloudfront (possibilité d'utiliser le certificat wildcard déjà généré)

Pour rendre le travail vous devez donner les informations suivantes :
- l'url de votre site final qui affiche le fichier index.html
- donner le lien github vers les fichiers terraform de déploiement

Chaque réalisation donnera des points (volume S3, Cloudfront, Lien entre S3 et Cloudfront, certificat SSL, Pointage DNS).
////////////////////////////////////////////////////////////

Voici url de mon site avec cloudfront et route53: [sametexam.devops.oclock.school](https://sametexam.devops.oclock.school/)

////////////////////////////////////////////////////////////
## Pour le certificat;

```tf
viewer_certificate {
    acm_certificate_arn      = "arn:aws:acm:eu-west-3:339713030032:certificate/ab119859-d359-4875-a799-31b986e7f58d"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
}
```
il donne une error malgre que j'ai copié le bon ARN;

```bash
Error: creating CloudFront Distribution: InvalidViewerCertificate: The specified SSL certificate doesn't exist, isn't in us-east-1 region, isn't valid, or doesn't include a valid certificate chain.
│       status code: 400, request id: a96c7207-f66f-49b6-b011-683df8188ee2
│ 
│   with aws_cloudfront_distribution.monsite-cdn,
│   on main.tf line 58, in resource "aws_cloudfront_distribution" "monsite-cdn":
│   58: resource "aws_cloudfront_distribution" "monsite-cdn" {
```
Donc, j'ai du le faire sur interface graphique.
