SELECT insert_ts, "TotalBuyTrade", "BestBuy", "StockCode", "Date", "TotalVal", "TotalSellTrade", "BestSellVol", "SpreadBSVol", "TotalSellVol", "SpreadBSTrade", "TotalVol", "TotalBuyVol", "BestBidVol", "ClosePrice", "BestSell"
	FROM public.sts_order;
	
-- CREATE UNIQUE INDEX sts_order_idx ON sts_order ("TotalBuyTrade", "BestBuy", "StockCode", "Date", "TotalVal", "TotalSellTrade", "BestSellVol", "SpreadBSVol", "TotalSellVol", "SpreadBSTrade", "TotalVol", "TotalBuyVol", "BestBidVol", "ClosePrice", "BestSell");
-- DROP INDEX sts_order_idx

SELECT insert_ts, "Date", "StockID", "LowestPrice", "ChangeColor", "TotalVol", "M_TotalVal", "BasicPrice", "MarketCap", "PT_TotalVol", "HighestPrice", "PerChange", "StockCode", "Change", "PT_TotalVal", "ClosePrice", "TrID", "AvrPrice", "ChangeImage", "TotalVal", "M_TotalVol", "OpenPrice"
	FROM public.sts_price;
	
-- CREATE UNIQUE INDEX sts_price_idx ON sts_price ("Date", "StockID", "LowestPrice", "ChangeColor", "TotalVol", "M_TotalVal", "BasicPrice", "MarketCap", "PT_TotalVol", "HighestPrice", "PerChange", "StockCode", "Change", "PT_TotalVal", "ClosePrice", "TrID", "AvrPrice", "ChangeImage", "TotalVal", "M_TotalVol", "OpenPrice");
-- DROP INDEX sts_price_idx

SELECT insert_ts, "BuyVol", "Date", "TotalRoom", "CurrRoom", "PerBuyVol", "BuyPutVal", "SellVal", "PerBuyPutVal", "SellPutVol", "DiffBuySellPutVol", "SellVol", "RemainRoom", "PerSellVol", "OwnedRatio", "StockCode", "SellPutVal", "BuyVal", "PerBuyVal", "PerSellPutVol", "PerSellPutVal", "DiffBuySellVol", "DiffBuySellVal", "DiffBuySellPutVal", "BuyPutVol", "PerSellVal", "PerBuyPutVol"
	FROM public.sts_foreign_mo;
	
-- CREATE UNIQUE INDEX sts_foreign_mo_idx ON sts_foreign_mo ("BuyVol", "Date", "TotalRoom", "CurrRoom", "PerBuyVol", "BuyPutVal", "SellVal", "PerBuyPutVal", "SellPutVol", "DiffBuySellPutVol", "SellVol", "RemainRoom", "PerSellVol", "OwnedRatio", "StockCode", "SellPutVal", "BuyVal", "PerBuyVal", "PerSellPutVol", "PerSellPutVal", "DiffBuySellVol", "DiffBuySellVal", "DiffBuySellPutVal", "BuyPutVol", "PerSellVal", "PerBuyPutVol");
-- DROP INDEX sts_foreign_mo_idx