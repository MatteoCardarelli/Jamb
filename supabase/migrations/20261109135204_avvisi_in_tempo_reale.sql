-- Pubblica le modifiche della bacheca su Realtime: la campanella si aggiorna
-- quando un altro capo pubblica un avviso. Realtime applica le RLS di
-- notice_board a chi è in ascolto, quindi ognuno riceve solo ciò che può leggere.

ALTER PUBLICATION supabase_realtime ADD TABLE public.notice_board;
