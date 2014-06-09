# Natural Products

## Notes 2014

With the latest FAO commodities data layers (processed by [data_prep.R](https://github.com/OHI-Science/ohiprep/blob/master/Global/FAO-Commodities_v2011/data_prep.R)), the following sequence of operations was performed on harvest, for both 1) value in **usd** normalized to the year 2000, and 2) quantity in metric **tonnes**:
- clean up files [remove Totals, translate FAO data codes (F, ..., -, 0 0, etc)]
- fill in all NAs after the first data per commodity with a 0
- carry previous year's value forward if value for max(year) is NA, at commodity level
- merge with commodities lookup and sum to the aggregate product level (see table below)
- convert country to rgn_id using new [`name_to_rgn_id()`](https://github.com/OHI-Science/ohiprep/blob/master/src/R/ohi_clean_fxns.R#L100-L205) function

Note that no georegional gapfilling has yet been applied.

Comparing input and output files in ohiprep:Global/FAO-Commodities_v2011/:
- raw/
  + [FAO_raw_commodities_quant_1950_2011.csv](https://github.com/OHI-Science/ohiprep/blob/master/Global/FAO-Commodities_v2011/raw/FAO_raw_commodities_quant_1950_2011.csv)
  + [FAO_raw_commodities_value_1950_2011.csv](https://github.com/OHI-Science/ohiprep/blob/master/Global/FAO-Commodities_v2011/raw/FAO_raw_commodities_value_1950_2011.csv)
- tmp/
  + [np_harvest_tonnes_wide.csv](https://github.com/OHI-Science/ohiprep/blob/master/Global/FAO-Commodities_v2011/tmp/np_harvest_tonnes_wide.csv)
  + [np_harvest_usd_wide.csv](https://github.com/OHI-Science/ohiprep/blob/master/Global/FAO-Commodities_v2011/tmp/np_harvest_usd_wide.csv)
- data/
  + [FAO-Commodities_v2011_tonnes.csv](https://github.com/OHI-Science/ohiprep/blob/master/Global/FAO-Commodities_v2011/data/FAO-Commodities_v2011_tonnes.csv)
  + [FAO-Commodities_v2011_usd.csv](https://github.com/OHI-Science/ohiprep/blob/master/Global/FAO-Commodities_v2011/data/FAO-Commodities_v2011_usd.csv)

![vs](https://raw.githubusercontent.com/OHI-Science/ohiprep/947e7488ee2aa67ac5aaf1d58c87d34001b5b41c/Global/FAO-Commodities_v2011/tmp/np_harvest_tonnes_wide_screen.png)

With these FAO harvest layers, we don't seem to have the same problems of the past analysis:
- **same max(year) per region-product**, so we don't need to stagger max(year) by product
- **no NAs for trailing years**, so we don't need to smooth and/or average

This is presumably because we are first summing across commodities to products, rather than dealing with individual commodities data. This in effect zeros out NA values of commodites as long as one of the commmodities within a region-year-product combo is available.



### Mismatches b/n quantity (tonnes) and value (USD)
Of all the region-product-year data (nrow=**12694**), only the following # of rows were NA per variable (ie after initial begin of non-NA data and possible trailing extension):

|var    | NAs|
|:------|---:|
|tonnes | 694|
|usd    | 214|


### FAO Commodities to NP Products

|product     |commodity                                              |
|:-----------|:------------------------------------------------------|
|sponges     |Natural sponges nei                                    |
|sponges     |Natural sponges other than raw                         |
|sponges     |Natural sponges raw                                    |
|fish_oil    |Alaska pollack oil, nei                                |
|fish_oil    |Anchoveta oil                                          |
|fish_oil    |Capelin oil                                            |
|fish_oil    |Clupeoid oils, nei                                     |
|fish_oil    |Cod liver oil                                          |
|fish_oil    |Fish body oils, nei                                    |
|fish_oil    |Fish liver oils, nei                                   |
|fish_oil    |Gadoid liver oils, nei                                 |
|fish_oil    |Hake liver oil                                         |
|fish_oil    |Halibuts, liver oils                                   |
|fish_oil    |Herring oil                                            |
|fish_oil    |Jack mackerel oil                                      |
|fish_oil    |Menhaden oil                                           |
|fish_oil    |Pilchard oil                                           |
|fish_oil    |Redfish oil                                            |
|fish_oil    |Sardine oil                                            |
|fish_oil    |Shark liver oil                                        |
|fish_oil    |Shark oil                                              |
|fish_oil    |Squid oil                                              |
|seaweeds    |Agar agar in powder                                    |
|seaweeds    |Agar agar in strips                                    |
|seaweeds    |Agar agar nei                                          |
|seaweeds    |Carrageen (Chondrus crispus)                           |
|seaweeds    |Green laver                                            |
|seaweeds    |Hizikia fusiforme (brown algae)                        |
|seaweeds    |Kelp                                                   |
|seaweeds    |Kelp meal                                              |
|seaweeds    |Laver, dry                                             |
|seaweeds    |Laver, nei                                             |
|seaweeds    |Other brown algae (laminaria, eisenia/ecklonia)        |
|seaweeds    |Other edible seaweeds                                  |
|seaweeds    |Other inedible seaweeds                                |
|seaweeds    |Other red algae                                        |
|seaweeds    |Other seaweeds and aquatic plants and products thereof |
|seaweeds    |Undaria pinnafitida (brown algae)                      |
|ornamentals |Ornamental saltwater fish                              |
|ornamentals |Ornamental fish nei                                    |
|corals      |Coral and the like                                     |
|shells      |Abalone shells                                         |
|shells      |Miscellaneous corals and shells                        |
|shells      |Mother of pearl shells                                 |
|shells      |Oyster shells                                          |
|shells      |Sea snail shells                                       |
|shells      |Shells nei                                             |
|shells      |Trochus shells                                         |

## Summary PLoS 2013
Level of protection of the coast from inundation and erosion compared to the local natural potential.

$$
x_{NP} = \frac{\sum_{p=1}^{N} w_p * x_p}{N};  
$$

$$
x_p = H_p * S_p;
$$

$$
S_p = 1 - (\frac{E + R}{N})  
$$

where:
- $w_p$ = proportional peak US dollar value of product $p$  
- $x_p$ = sustainable-harvest score for product $p$
- $H_p$ = harvest yield for product $p$  
- $S_p$ = sustainability of product $p$
- $E$ = exposure term
- $R$ = risk term

￼products: ornamentals, corals, sponges, shells, seaweeds, fish_oil

## Summary Nature 2012

$$
X_p = H_p * S_p
$$

where:
- $H_p$ is the harvest level for a product relative to its own (buffered) peak reference point
- $S_p$ is the sustainability of that harvest, with:

$$
S_p = 1 - (E + R) / N_v
$$

where:
- $E$ is the exposure term
- $R$ is the risk term
  + corals = 1
  + ornamental fish = relative intensity of cyanide fishing
- $N_v$ is 1 or 2 depending on whether or not a viability term is used   

or simplified to R code: `S_p = 1 - mean(c(E, R), na.rm=T)`

**Trend** per product:
- calculated the Status score for each product for the previous five years
- used the slope of these Status scores to calculate the Trend for each product
- Note that for the Trend calculation, some regions have staggered years between products for the slope calculations:
  + 2003-2007 for **Corals, Ornamental Fish, and Shells**
  + 2004-2008 for the rest

**Score** per region, summarized status or trend:
To create a single score for the Natural Products goal ($x_NP$) we then took the weighted average of the individual product scores, such that:

$$
x = \sum{\frac{w_p * x_p}{N}}
$$
where:
- $N$ is # of products
- $w_p$ is **proportional peak dollar** value of ea product relative ot the total peak dollar value of all products (2008USD). If a product had a peak value, but was missing a harvest value for that product in a given year, then we used wp = 0 during the aggregation for that year.
- $x_p$ is individual score: status or trend

##  Harvest scores

#### From Nature 2012:
- **max per country**. For the Status of each product, we assessed the most recent **harvest rate (in metric tons)** per country _relative_ to the **maximum value (in 2008 USD)** ever achieved in that country. This creates a reference point internal to each country. 
- **buffer w/in 35% of peak set to 1**, values _below that rescaled_ to this 35% buffer value.
- For countries that never harvested a product, we assumed they cannot produce it (in general because the product does not exist there) and so treat that as a ‘no data’ rather than a zero value. __For countries that harvested a product at any point in time__, **empty values are treated as zeros** since the country clearly has the capacity to harvest that product.

#### From PLoS 2013:
- **Mismatches b/n harvest & monetary value reported**, one or the other for any given year.Because of inconsistencies with how data are reported to FAO on the harvest and monetary value of each product (many countries report only one or the other of the two measures in a given year), there are many cases where harvest data but no value data are reported, and equal numbers of cases with value data but no harvest data. These mismatches in reporting would cause products to ‘drop out’ of the calculation of overall status, thus losing real data.  Because a reported US dollar value must come from the harvesting of a product, and similarly the reporting of harvested tonnage implies some economic value of that product, we developed several methods to _fill these gaps_.
  1. **smoothed harvest data with a 4-year moving window** (skipping missing values rather than treating them as 0) to help fill gaps and minimize the potential effect of under- or over-reporting of annual harvest.       
  2. **averaged all non-null monetary values** reported for each product over the previous **15 years** (inclusive of current year), thus ensuring that an estimate of current value of the product is given even when the product is no longer harvested.  In some cases there were no data reported within this time period and so we averaged up to the previous **25 years** to get a non-zero value (i.e., we extended the length of time for which values were averaged until a non-zero value was returned).

###### Layer 5.52. Natural Products harvest 
Updated data were available through 2009 for all Natural Products categories (sponges, fish oil, seaweed and plants, ornamental fish, corals, shells), 
which were accessed from FAO using FishstatJ 2.0.0 (www.fao.org/fishery/statistics/software/fishstatj/en). 
Only export data were used, with commodity types and their subcategories accessed the same way as in the 2012 assessment, 
although some subcategories are no longer reported (Agar agar in blocks, Laver smoked, Rock laver)

###### Layer 5.53. Natural Products value
Update: additional year(s) available.
Description: Updated data on the value (export revenue) for all products were available except seaweeds and plants.  
- For that product, we used the **average price per tonne** for countries in 2008 (**$8,520/tonne**) and _applied that value to harvest yields_ to produce a per-region value **for seaweeds and plants**.
- These value data are then used to determine the **proportional contribution of each natural product** to the score within a region. To determine proportional values for recalculated 2012 scores, we _used proportions determined previously (Halpern et al. 2012)_ for all regions that were not split into smaller reporting regions; for regions that were split (see section 2 above), we instead used values from the current assessment to avoid mis-attributing harvest of a product to one of the smaller regions (for example, coral harvest in a region that does not have coral).

###  Sustainability 

#### From Nature 2012...

Sustainability term for each product used to adjust harvest level. It is based on:
- the **log-transformed intensity of harvest per km2** of **coral and/or rocky reef**, depending on the product, _relative to the global maximum_ (its ‘exposure’), 
- and for **ornamental fish and corals** also the **‘risk’** that is associated with known unsustainable harvest practices (i.e., the intensity of cyanide fishing for ornamental fish, and any harvest of corals since they are CITES protected species).
- **Fish oil**, **exposure** was calculated based on stock status assessments. 
  + For each country we calculated the **weighted proportion of species harvested sustainably**. 
  + We assigned each species an **exploitation status** based on its catch each year relative to its MSY over the span of the database, 1950-2006, following the definitions in Table S6 which are based on FAO definitions plus the ‘rebuilding’ category developed by the Sea Around Us Project40. 
  + When insufficient information exist to assign a stock status, the stock was excluded from analyses.

  $$
  S_{t,p} = \sum{\frac{N_k * w_k}{N_k}}
  $$

  where:  
  - $N_k$ is # of spp in ea $k$ category of exploitation and 
  - $w$ is weight assigned by Table S6: `c('Developing'=1, 'Fully exploited'=1, 'Overexploited'=0.5, Collapse='0', 'Rebuilding'=0.25)`

#### From PLoS 2013...

- The sustainability component for fish oil was changed for 2013.
- We also had to gap fill a few of the sustainability scores for products when yield was reported but no habitat existed in the region with which to calculate exposure (see Halpern et al. 2012). 
- In these cases we used the regional average across all other regions with sustainability scores 
  + ornamentals: 2013 filled value=0.946, 2012 filled value=0.942, N=28; 
  + corals:   2013=0.389, 2012=0.383, N=28
  + sponges:  2013=0.974, 2012=0.974, N=22
  + shells:   2013=0.916, 2012=0.911, N=19
  + seaweeds: 2013=0.817, 2012=0.823, N=28

##### Layer 5.51. Natural Products exposure
Update: additional year(s) available
Description: **Extent of rocky and coral reef habitat**, which _in combination with harvest rates_ are used to estimate this exposure term, were _not updated from previous estimates_. We were able to update harvest rates (see next data layer), allowing this exposure parameter to reflect those changes.

###### Layer 5.54. Natural Products risk
Update: additional year(s) available.
Description: This data layer was previously labeled “Convention on International Trade in Endangered Species of Wild Fauna and Flora (CITES) listed species” but has been 
renamed here for clarity on how the data were used. 
Sustainability risk for each of the Natural Products commodities was assessed separately and was included in the sustainability equation when data were available. 
Risk assessment for: 
- **corals** was based on species identified by CITES; risk for all corals was set as **1** since species in both subclasses and multiple orders of extant corals in class Anthozoa are listed in CITES Appendices II and III (www.cites.org/eng/app/appendices.php). 
- No **sponges, algae or marine plants** were listed in CITES and thus their risks were set at **0**. 
- **Shells** were also set as **0** since species were not listed individually in the FAO database and only one marine genus (Tridacnidae spp.) and one marine species (Lithophaga lithophaga) were identified in CITES Appendix II. 
- Risk for **ornamental fish** was set based on assessments of **cyanide or dynamite fishing** by Reefs at Risk Revisited (www.wri.org/publication/reefs-at-risk-revisited) under the assumption that most ornamental fishes are harvested from coral reefs. 
- For **fish oil** sustainability, the previous data-poor estimate of stock status (Klesiner & Pauly, 2012) was replaced by a **weighted geometric mean of estimated B/BMSY** that also corresponds to the **fisheries sub-goal status** (see section 4.1.1). As was true for the previous iteration, it is not possible to identify which of the species fished in the area are used to extract the fish oil. Therefore the estimate is based on all the stocks harvested.


## NP README
path: `neptune:local/src/model/global2013/NP/README.txt`

    Source: GL-NCEAS-NaturalProducts, GL-NCEAS-StockStatus, GL-NCEAS-Halpern2008, GL-WRI-ReefsAtRisk
    
    See "Natural Products Modeling Summary_9_26.docx".
    
    See "Computing Stock status.docx" for Fish Oil S1 methods.
    
    STATUS
    
    We calculated a status score for each product for each region in 2008. We gave
    a zero for yield for any country with yield data prior to 2008 but no data for
    2008 in the fish oil, seaweeds, and sponges product, and prior to 2007 for
    shells, ornamentals, and corals.
    
    To calculate a "combo" layer, we use the relative peak values (in 2008USD) per
    product per region. All product weights are represented in 2008.
    
    New items for 2 Nov:
    
    - New combo layer that omits corals called "combo-without-corals". It has new
      subregion and synthesis reports.
    
    - Calculate all H_p_i values, relative to 65%% of peak yield and capped to a
      maximum of 1. This change impacts nearly all status and trend scores for all
      products.
    
    - Using the revised stock status data for fish oil sustainability (S1). For
      status, we use the 2006 value per country, and for trend we use the
      2004-2006 actuals and use 2006 for 2007 and 2008. Note that we use these
      scores as-is -- i.e., a lower score represents higher exploitation.
    
    - Fish oil yield and value data now omits marine mammal oils.
    
    To calculate a "combo" layer, we use the relative peak values (in 2008USD) per
    product per region. If a product had a peak value for a given country, but is
    missing a status value for that product in the given year, then we give that
    product a status of 0 during the aggregation. Note that for the trend
    calculation, the combo layer has staggered years between the 2003-2007
    products and 2004-2008 products.

The aggregation by country into reporting regions was limited to 4 regions (ID
85 106 115 126).

```sql
CREATE TABLE product_weights AS
SELECT  d.iso3166, d.product, 
        CASE  WHEN total.value > 0
              THEN d.value_peak/total.value  
              ELSE 0
        END AS value
FROM  product_peaks d
JOIN (
    SELECT  iso3166, SUM(value_peak) AS value
    FROM    product_peaks
    GROUP BY iso3166
) total USING (iso3166)
ORDER BY d.iso3166, d.product
;
```