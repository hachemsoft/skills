---
name: jira-get-ticket
description: Retrieve Jira issue details via the Atlassian MCP tools and produce an actionable fix/dev plan. Use when the user asks to récupérer/consulter un ticket Jira, fetch an issue, or references a key like PROJ-123.
---

# Jira: récupérer un ticket

## Objectif

Récupérer les détails d'un ticket Jira (story/bug/task) à partir d'une **clé** (ex: `ABC-123`) ou, si besoin, via une **recherche JQL**, puis produire un **plan de fix/dev** actionnable.

## Prérequis

Les tools MCP Atlassian (`getJiraIssue`, `searchJiraIssuesUsingJql`, `getAccessibleAtlassianResources`) doivent être disponibles (serveur `atlassian` déclaré dans le `.mcp.json` du repo). S'ils n'apparaissent pas, utiliser ToolSearch pour les charger. Si le serveur n'est pas connecté, demander à l'utilisateur de lancer `/mcp` pour s'authentifier (OAuth Atlassian).

## Workflow fiable (à suivre dans cet ordre)

### 1) Obtenir le `cloudId`

- Si l'utilisateur donne un site Jira (ex: `company.atlassian.net`), tenter d'utiliser le **hostname** comme `cloudId`.
- Si ce n'est pas connu ou si l'appel échoue, appeler `getAccessibleAtlassianResources` et choisir le `cloudId` correspondant au bon site Jira.

### 2) Récupérer le ticket par clé

Appeler `getJiraIssue` avec:
- `cloudId`
- `issueIdOrKey` (ex: `ABC-123`)

Recommandations:
- Utiliser `responseContentFormat: "markdown"` quand le but est d'afficher un texte lisible.
- Limiter `fields` pour éviter des réponses trop grosses.

Champs par défaut recommandés (adapter si nécessaire). Si l'objectif est de préparer un plan de dev/fix, privilégier au minimum:
- `summary`, `description`, `status`, `priority`, `issuetype`
- `assignee`, `reporter`, `project`, `labels`, `components`, `fixVersions`
- `created`, `updated`

### 3) Si la clé n'est pas connue: recherche JQL

Appeler `searchJiraIssuesUsingJql` avec:
- `cloudId`
- `jql`
- `maxResults` (10 par défaut, ≤ 100)

Stratégie:
- Retourner une liste courte (clé + summary + status) des meilleurs résultats.
- Demander (ou choisir avec le contexte) la clé la plus probable, puis appeler `getJiraIssue`.

Exemples de JQL:
- `text ~ "paiement" ORDER BY updated DESC`
- `project = ABC AND statusCategory != Done ORDER BY priority DESC, updated DESC`
- `assignee = currentUser() ORDER BY updated DESC`

## Format de sortie (recommandé)

Quand le ticket est récupéré, produire:
- **Key + Summary**
- **Status / Priority / Type**
- **Assignee / Reporter** (si présents)
- **Description** (si utile, sinon omettre ou résumer)
- **Dates**: created / updated

## Plan de fix/dev (obligatoire après récupération)

Après avoir récupéré le ticket, générer un plan concret sous ce format (même si certaines sections restent en hypothèses):

```markdown
## Synthèse du ticket
- **Problème / besoin**:
- **Comportement actuel**:
- **Comportement attendu**:
- **Contexte / contraintes** (env, roles, perf, sécurité, compat, SLA):

## Hypothèses & questions (si le ticket est incomplet)
- H1:
- Q1:

## Périmètre technique pressenti
- **Zones impactées** (backend/frontend/DB/jobs/CI/infra):
- **Risques** (régression, data, migration, perf):
- **Dépendances** (feature flags, services externes, permissions):

## Stratégie de correction / implémentation
- **Approche**:
- **Points d'attention**:
- **Plan de rollback** (si changement risqué):

## Tâches détaillées (checklist)
- [ ] Repro / état initial (logs, étapes, données)
- [ ] Ajout/ajustement tests (unit/int/e2e)
- [ ] Implémentation
- [ ] Migrations/fixtures (si besoin)
- [ ] Observabilité (logs/metrics/alert)
- [ ] QA / validation

## Plan de test
- **Cas nominal**:
- **Cas limites**:
- **Non-régression**:
```

Règles:
- Si c'est un **bug**, commencer par un **plan de repro** (préconditions + steps + résultat observé).
- Si c'est une **feature**, extraire/inférer des **critères d'acceptation** (Given/When/Then) avant de lister les tâches.
- Ne pas inventer des "détails produit" sans le signaler: toute supposition doit aller dans **Hypothèses & questions**.
- Ancrer le plan dans le bon repo du projet (si plusieurs repos/services, identifier lequel est concerné avant de détailler les tâches).

## Exemples (déclencheurs)

- "Récupère le ticket `ABC-123`"
- "Tu peux me donner le détail de `OPS-42` ?"
- "Cherche le ticket lié à *mutualisation* dans Jira"
- "À partir de `ABC-123`, fais un plan de fix/dev"
