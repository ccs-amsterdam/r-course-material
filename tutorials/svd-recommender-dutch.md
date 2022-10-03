Aanbevelingen met Singular Value Decomposition
================
Wouter van Atteveldt
2022-10

-   [Singular Value Decomposition](#singular-value-decomposition)
    -   [M = UDV’](#m--udv)
    -   [Minder factoren](#minder-factoren)
-   [Collaborative filtering](#collaborative-filtering)
    -   [Gegevens](#gegevens)
    -   [SVD](#svd)

In deze handout gebruiken we ‘Singular Value Decomposition’ met de `svd`
functie om aanbevelingen te doen met behulp van *collaborative
filtering*: door latente factoren te vinden in de matrix van user
ratings kunnen we voorspellen wat iemand zou vinden van een item (film,
boek, nieuwsartikel) dat nog geen rating heeft.

De kerngedachte hierachter is dat deze latente factoren een soort
voorkeuren voorstellen, dat wil zeggen dat films (of andere items) die
vaak door dezelfde mensen leuk gevonden worden, op dezelfde factor
zullen zitten. Als ik dus weet dat ik een aantal films van een bepaalde
factor leuk vindt, dan is de kans groot dat ik ook andere films van die
factor leuk zal vinden. Met andere woorden: die andere films zijn films
die ‘mensen als ik’ leuk vinden.

In het eerste deel van de tutorial kijken we hoe SVD werkt, in het
tweede deel passen we het toe op simpele review data.

# Singular Value Decomposition

Stel dat we data hebben met twee dimensies (*x* en *y*) die sterk
gecorreleerd zijn. We ‘maken’ nu even dit soort gegevens door x
willekeurig uit een normaalverdeling te trekken, en y te berekenen op
basis van x en een afwijking: `y = .5·x + e`:

``` r
library(tidyverse)
data = tibble(x = rnorm(100)) |>
  mutate(y = .5*x + rnorm(length(x), sd=.25))
cor.test(data$x, data$y)
ggplot(data, aes(x=x, y=y)) + geom_point() 
```

Zoals je kan zien zijn x en y heel sterk gecorreleerd, en is de scatter
plot een soort ellipse om de diagonaal heen.

Een manier om hier naar te kijken is dat er eigenlijk een *latente
factor* is waarmee zowel *x* als *y* te verklaren zijn. Deze factor is
de diagonale lijn waar de punten omheen zitten: alle punten zitten
behoorlijk dicht bij deze lijn, dus als je in plaats van de *x* en *y*
alleen maar het punt op die lijn zou weten, zou je nooit heel ver van
het oorspronkelijke punt af zitten.

In dit geval hebben we de data zelf gegenereerd en weten we dus dat deze
structuur erin zit, maar hoe kunnen we vinden welke latente factoren er
in gegevens zitten?

## M = UDV’

Met singular value decomposition kan je elke (normale) matrix ontleden
in drie componenten:

-   *U* geeft van elke rij (gebruiker) hoe sterk deze in elke factor zit
-   *D* is de ‘singular value’ (sterkte) van elke factor
-   *V’* geeft van elke kolom (film, boek, etc) hoe sterk deze in elke
    factor zit

``` r
udv = svd(data)
u = udv$u
d = udv$d
v = udv$v
d
dim(u)
```

Zoals je kan zien bevat het resultaat van `udv` deze data, en is `u` een
matrix van 100 (rijen) x 2 (factoren).

Als je deze drie matrices weer met elkaar vermenigvuldigd krijg je
precies dezelfde data weer terug:

``` r
data2 = u %*% diag(d) %*% t(v)
colnames(data2) = colnames(data)
```

Om dit te testen zetten we het om in een tibble en plotten we de data:

``` r
data2 |> as_tibble() |>
  ggplot(aes(x=x, y=y)) + geom_point()
```

## Minder factoren

Het is natuurlijk niet heel nuttig om allemaal berekeningen uit te
voeren om weer bij dezelfde gegevens te komen.

Wat echter wel nuttig is is dat de *singular values* in d in volgorde
van belangrijkheid staan. Door alleen de eerste *p* factoren te
gebruiken, kunnen we dus de latente structuur van de data zien.

In dit geval willeen we maar 1 factor overhouden. De makkelijkste manier
om dit te doen is de singular value voor de andere factor(en) op nul te
zetten:

``` r
d[2] = 0
data2 = u %*% diag(d) %*% t(v)
colnames(data2) = c("x2", "y2")
data2 = as_tibble(data2)
```

Als we het nu plotten dan zijn alle punten op de diagonaal (de latente
factor) geprojecteerd:

``` r
ggplot(data2, aes(x=x2, y=y2)) +  geom_point()
```

Dit is nog beter te zien als we de oorspronkelijke punten erbij plotten:

``` r
d = bind_cols(data, data2) |> mutate(i=row_number()) 
ggplot(d) + 
  geom_segment(data=head(d, 20), aes(x=x, y=y, xend=x2, yend=y2), lty=2, color='grey') +
  geom_point(aes(x=x, y=y), color='grey', shape="triangle")+
  geom_point(aes(x=x2, y=y2))+
  geom_point(data=head(d, 20), aes(x=x2, y=y2, color=as.factor(i))) +
  geom_point(data=head(d, 20), aes(x=x, y=y, color=as.factor(i)), shape="diamond", alpha=.5)+
  coord_fixed() + theme_minimal() + 
  guides(color="none")
```

In de plot hierboven zie je de oorspronkelijke punten in het grijs, en
de projectie op de latente factor in zwart. Voor de eerste
(willekeurige) 20 punten zijn de bij elkaar horende punten gekleurd en
is de projectielijn in het grijs weergegeven. Zoals je kan zien is elk
punt loodrecht op de factor geprojecteerd.

# Collaborative filtering

Zoals in het begin gezegd kunnen we deze techniek gebruiken om
aanbevelingen te doen: Door de user-item matrix met de ratings te
ontleden in een kleiner aantal latente factoren, kunnen we kijken welke
items (films, boeken, etc) vaak dezelfde rating hebben: gebruikers
vinden de items op een factor vaak allemaal leuk of juist niet.

## Gegevens

Om te kijken hoe dit werkt gebruiken we een triviale dataset met 8 films
en 10 gebruikers:

``` r
m = read_csv("https://raw.githubusercontent.com/ccs-amsterdam/r-course-material/master/data/reviews.csv") 
m
```

Olivia houdt erg van F1 en Home Game, maar niet van House of Cards of
Bridge. De eerste stap is om dit om te zetten naar een matrix met de
series in de kolommen. Hiervoor gebruiken we de `pivot_wider` functie:

``` r
m = pivot_wider(m, names_from=series, values_from=rating, values_fill=0)
m
```

Nu kunnen we de de `user` kolom in rijnamen veranderen en er een matrix
van maken:

``` r
m = m |> 
  column_to_rownames(var="user") |>
  as.matrix()
m
```

## SVD

``` r
udv = svd(m)
u = udv$u
d = udv$d
v = udv$v
```

Als we kijken naar de singular values dan zien we dat er een soort knik
zit bij n=3 of n=4:

``` r
tibble(n=1:8, value=d) |> 
  ggplot(aes(x=n, y=value)) + 
  geom_line() + 
  theme_minimal()
```

Gezien het kleine aantal datapunten gaan we uit van 3 factoren. We
gebruiken dezelfde code als eerste om onze ‘voorspellingen’ van de
ratings te doen:

``` r
d[4:length(d)] = 0
data2 = u %*% diag(d) %*% t(v)
colnames(data2) = colnames(m)
rownames(data2) = rownames(m)
round(data2, 1)
```

Wat we nu zien is dat alle waardes ingevuld zijn: met andere woorden we
hebben een inschatting of voorspelling van de rating van een serie, ook
als deze nog niet door die persoon was gekeken.

Op basis van deze matrix kunnen we een aanbeveling doen, namelijk de
ongekeken serie met de hoogste voorspelde waardering.

Voor sport-fan Olivia komen we dan bijvoorbeeld op *Ronaldo vs Messi*,
terwijl we voor Lucas, die een groot fan is van *Borgen* en *the Bridge*
juist *House of Cards* zouden aanbevelen.

Wat hier dus interessant aan is is dat de computer ‘snapt’ welke films
bij elkaar horen, zonder dat wij een genre of categorie hebben gegeven.
Deze techniek gebruikt dus geen enkele informatie over het product, maar
kijkt alleen naar patronen in de reviews.

Uiteraard is dit een klein voorbeeld, maar hoe meer gebruikers en
ratings de computer heeft hoe beter hij kan voorpellen wat een geburiker
van een andere serie, film of boek zou vinden.
