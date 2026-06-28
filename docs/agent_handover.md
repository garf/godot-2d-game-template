# Agent Handover

Short list of known follow-up issues for future agents:

- `ItemDb` still has placeholder resource and scene paths. Do not assume items are wired.
- SFX still use a local dictionary in `SfxPlayer`. Add an SFX DB only when sound list grows.
- Input action names are still raw strings in gameplay code. Consider centralizing them if controls expand.
- Enemy/object architecture is still minimal. Reuse `HitboxComp`, `HurtboxComp`, `HpComp`, and event patterns before adding new systems.
- Manual playtest coverage is important because project has no automated tests yet.
