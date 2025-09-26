--select count(*) cnt,token from repeat group by token order by cnt desc, token asc
--select count(*) cnt,token,repeated_line, length(token) token_len from repeat group by token order by  token_len asc

-- Repeat table was removed, use redundancia table instead:
-- SELECT file_name, max_ismetelt_karakterszam, overview FROM redundancia ORDER BY max_ismetelt_karakterszam DESC;
