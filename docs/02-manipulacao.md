# (PART\*) Parte I  {-}

# Manipulação de dados {-}


## Warm-Up {-}


### Conhecendo os dados {-}

Vamos começar importando os dados do arquivo `input/jpf_ifc_ms.xlsx`. Para indicar que o arquivo está dentro de uma pasta, é preciso utilizar a barra `/`, 


```r
library(tidyverse)
library(readxl)

tab_ifc <- read_excel("input/jpf_ifc_ms.xlsx")

tab_ifc
```

Primeiro vamos fazer um histograma para poder ver a distribuição da variável `imatcc`.


```r
ggplot(data = tab_ifc, aes(x = imatcc)) +
  geom_histogram() 
```

Agora, vamos ver a relação entre o `dap` e o `altura` dos filmes.


```r
ggplot(data = tab_ifc, aes(x = dap, y = altura)) +
    geom_point()
```



```r
ggplot(data = tab_ifc, aes(x = dap, y = altura)) +
  geom_point() +
  geom_smooth()
```


### Qual o lucro médio dos filmes? {-}

Nosso objetivo agora é calcular o lucro médio dos filmes. Primeiro vamos criar uma coluna e calcular o lucro de cada filme.


```r
tab_ifc_modificado <- mutate(tab_ifc, vol_individual = pi * dap^2 * 1/4000 * altura * 0.5)
tab_ifc_modificado
```

Vamos isolar os valores de lucro e colocar em um objeto e em seguida calcular a média.


```r
vec_vol_individual <- pull(tab_ifc_modificado, vol_individual)

mean(vec_vol_individual)
```

Vamos refazer os 2 primeiros passos unindo os comandos em um só.


```r
vec_vol_individual <- pull(mutate(tab_ifc, vol_individual = pi * dap^2 * 1/4000 * altura * 0.5))

mean(vec_vol_individual)
```

Seguindo a mesma ideia, podemos unificar todos os comandos em uma única chamada.


```r
mean(pull(mutate(tab_ifc, vol_individual = pi * dap^2 * 1/4000 * altura * 0.5), vol_individual))
```

Agora utilizando um operador especial chamado `pipe`, vamos executar as mesmas funções, porém de forma organizada e de fácil interpretação.


```r
tab_ifc %>% 
  mutate(vol_individual = pi * dap^2 * 1/4000 * altura * 0.5) %>% 
  pull(vol_individual) %>% 
  mean()
```


## Sobre o Tidyverse {-}

Neste curso utilizaremos como referência os pacotes vinculados ao `tidyverse`, grupo de funções que utilizam a mesma filosofia de programação e foram desenvolvidos para atuarem em conjunto. O [tidyverse](https://www.tidyverse.org/) é mantido por um time de desenvolvedores do RStudio e liderado pelo seu idealizador [Hadley Wickham](http://hadley.nz/).

Há diversas funções disponíveis nos pacotes do `tidyverse` que tem um equivalente direto nos pacotes `base` do R, mas com uma implementação mais moderna e consistente que facilita a estruturação do código. No decorrer do curso vamos ter vários exemplos desse comparativo.

A manipulação de dados é, na maioria das vezes, realizado com `data.frames` e por isso iremos ver as principais funções que lidam com essa estrutura de forma rápida e prática.

O pacote `dplyr` é hoje um dos pacotes mais utilizados para esta finalidade. Ele disponibiliza diversas funções que são “equivalentes” às funções básicas do R, mas como melhorias que nos poupam tempo e deixam o código muito mais fácil de interpretar.

Como exemplo, vamos realizar uma análise exploratória dos dados de um inventário na floresta amazônica.


```r
library(tidyverse)
library(readxl)
```


```r
tab_clima <- read_excel("input/jpf_clima.xlsx")

tab_clima
```


### Filter {-}

Com a função `filter()` é possível selecionar linhas específicas, de acordo com o fator que se deseja. Podem ser usados um ou vários fatores de seleção.


```r
filter(tab_clima, tmed > 32)
```


```r
filter(tab_clima, tmed > 32 & ppt < 10)
```


```r
filter(tab_clima, tmed > 32 | ppt > 400)
```


```r
filter(tab_clima, site == "ribas")
```


```r
filter(tab_clima, site %in% c("ribas", "tres_lagoas"))
```


### Arrange {-}

Para ordenar as colunas, podemos usar a função `arrange()`. A hierarquia é dada pela sequência dos fatores que são adicionados como argumentos da função.


```r
arrange(tab_clima, tmed)
```


```r
arrange(tab_clima, -tmed)
```


### Select {-}

A função `select()` auxilia-nos na seleção de variáveis (colunas).


```r
select(tab_clima, site, ano, mes, ppt)
```


```r
select(tab_clima, site:doy)
```


```r
select(tab_clima, -(seq:lat))
```


### Mutate {-}

Para criar novas variáveis, podemos usar a função `mutate()`. Um diferencial dessa função em relação à função base do R, é que podemos utilizar variáveis criadas dentro do próprio comando.


```r
mutate(
  tab_clima,
  temp_otima = tmed >= 18 & tmed <= 22
)
```

Note que se quisermos utilizar os dados calculados no futuro, temos de salvar em um objeto. No caso, vamos salvar no mesmo objeto `tab_clima2` de forma que ele será atualizado com as novas colunas.


```r
tab_clima_modificado <- mutate(
  tab_clima,
  temp_otima = tmed >= 18 & tmed <= 22
)
```


### Summarise {-}

A função `summarise` nos permite resumir dados. Também é possível resumir dados em função de vários fatores com o `group_by`.


```r
summarise(tab_clima, tmed_media = mean(tmed))
```


```r
summarise(tab_clima, ppt_media = mean(ppt))
```


```r
tab_clima_agrupado_ano <- group_by(tab_clima, ano)

summarise(tab_clima_agrupado_ano, tmed_media = mean(tmed))
```


```r
tab_clima_agrupado_site_ano <- group_by(tab_clima, site, ano)

tab_clima_site_ano <- summarise(
  tab_clima_agrupado_site_ano,
  tmed_anual = mean(tmed),
  ppt_anual = sum(ppt)
)

tab_clima_site_ano 
```


```r
filter(tab_clima_site_ano, ppt_anual < 700)
```


### Operador %>% {-}

O pacote `dplyr` foi desenhado para trabalhar em conjunto que o operador em cadeia `%>%`. O que esse operador faz é aplicar o que está no LHS no primeiro parâmetro da função do RHS. Podemos também direcionar o local onde o conteúdo do LHS será aplicado informando um `.` como argumento.


```r
tab_clima %>%
  group_by(site, ano) %>% 
  summarise(
    tmed_anual = mean(tmed),
    ppt_anual = sum(ppt)
  ) %>% 
  filter(ppt_anual < 700)
```


```r
tab_clima %>% 
  filter(site == "ribas", mes == 1) %>% 
  select(site, ano, mes, tmed) %>% 
  arrange(desc(tmed)) %>% 
  slice(1:5)
```


### Gráficos rápidos {-}


```r
tab_clima %>% 
  group_by(site, mes) %>% 
  summarise(
    tmed_mensal = mean(tmed)
  ) %>% 
  ggplot(aes(mes,tmed_mensal, color = site)) +
    geom_line() +
    scale_x_continuous(breaks = 1:12) +
    theme_bw()
```

```r
tab_clima %>%
  group_by(site, ano) %>% 
  summarise(ppt_anual = sum(ppt)) %>% 
  ungroup() %>% 
  mutate(site = fct_reorder(site, ppt_anual)) %>% 
  ggplot(aes(ano, site, fill = ppt_anual)) +
    geom_tile() +
    scale_fill_viridis_b() +
    theme_bw()
```



```r
tab_ifc %>% 
  group_by(matgen) %>% 
  summarise(imatcc = mean(imatcc)) %>% 
  top_n(10, imatcc) %>% 
  mutate(matgen = fct_reorder(matgen, -imatcc)) %>% 
  ggplot(aes(matgen, imatcc)) +
    geom_col() +
    theme_bw()
```


```r
tab_ifc %>% 
  ggplot(aes(area_basal, altura_dom)) +
    geom_point(alpha = 0.03) +
    geom_smooth(method = "lm") +
    theme_bw()
```
