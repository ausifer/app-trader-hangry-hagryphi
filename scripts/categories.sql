ELECT DISTINCT TRIM(name) AS name,
        rating,
        store,
        cost,
        INITCAP(
			CASE WHEN category ILIKE '%Game%' THEN 'Games'
				WHEN category ILIKE '%Health%' THEN 'Health & Fitness'
				WHEN category ILIKE '%Food%' THEN 'Food & Drink'
			WHEN category ILIKE '%Lifestyle%' THEN 'Lifestyle'
			WHEN category ILIKE '%Education%' THEN 'Education'
			WHEN category ILIKE '%Family%' THEN 'Family'
			WHEN category ILIKE '%Book%' THEN 'Lifestyle'
			WHEN category ILIKE '%Medical%' THEN 'Medical'
			WHEN category ILIKE '%Family%' THEN 'Family'
						ELSE category END
		) AS category,
        expected_lifespan_in_years,