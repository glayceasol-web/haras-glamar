# Haras GLAMAR · site próprio (Vercel + Supabase)

## 1. Supabase (banco de dados e login)
1. Crie o projeto `haras-glamar` (região São Paulo).
2. Abra **SQL Editor → New query**, cole todo o conteúdo de `supabase-setup.sql` e clique em **Run**.
3. Abra **Authentication → Sign In / Providers** e desligue **Allow new users to sign up** (assim só entra quem você cadastrar).
4. Abra **Authentication → URL Configuration** e coloque em **Site URL** o endereço do site na Vercel (ex.: `https://haras-glamar.vercel.app`).
5. Crie o seu acesso: **Authentication → Users → Add user → Create new user**, com seu e-mail e senha, marcando **Auto Confirm User**. O primeiro usuário criado vira **Administrador**.
6. Copie em **Project Settings → API** a *Project URL* e a chave *anon public* e coloque no arquivo `config.js`.

## 2. Vercel (endereço do site)
1. **Add New → Project → Import** o repositório `haras-glamar` do GitHub.
2. Framework: **Other**. Não precisa de comando de build. Clique em **Deploy**.

## 3. Equipe
Para cada pessoa: **Supabase → Authentication → Users → Add user** (e-mail, senha, Auto Confirm).
Depois, no site, em **Configurações → Usuários e perfis**, escolha o perfil: Administrador, Financeiro, Usuário ou Somente leitura.
