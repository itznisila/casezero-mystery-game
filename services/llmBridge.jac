# Server-only model bridge. The provider and key come from jac.toml ([byllm.model]),
# which reads LLM_MODEL and GEMINI_API_KEY from the server environment.
# This is the ONLY place a model is called. services/advisors.jac wraps it with
# a rules-only fallback and an output guard, so the game never depends on it.
#
# instructions : the role and hard limits for this reply
# facts        : the only facts the reply may use
# request      : what the player asked
# draft        : the deterministic answer to rewrite in the role's voice
def llm_compose(instructions: str, facts: str, request: str, draft: str) -> str by llm();
