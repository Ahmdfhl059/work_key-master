# Explore Jobs integration

## Endpoints

- `GET /api/v1/reference/job-filters` loads the localized filter and sort contract.
- `GET /api/v1/jobs` powers Latest and All Jobs with search, applied filters, sort parameters, `page`, and `per_page`.
- `GET /api/v1/jobs/recommended?limit=20` powers For You only when a token exists.
- Autocomplete endpoints and their search/value/label fields come from `options_source`.

## Dynamic filters

The renderer supports `single_select`, `boolean`, `autocomplete`, and `range`. Unknown types are ignored. Filters retain backend order. `visible_when` currently supports `has_value`; hidden filter values are removed when results are applied. Draft changes stay inside the sheet until **Show results** is pressed. Reset restores backend defaults.

## Tabs and state

- **For You:** authenticated users only; no local search, filters, or pagination are sent.
- **Latest:** uses `/jobs` and the backend `newest` sort option parameters.
- **All Jobs:** uses `/jobs`, backend sort options, filters, search, and infinite pagination.

Each tab keeps independent items and pagination. Duplicate jobs are removed by ID. Search uses a 400 ms debounce. Pull-to-refresh reloads page one.

## Localization and failure behavior

`Accept-Language` uses the cached app language. Labels returned by the backend are displayed unchanged. If the filter contract fails, search and jobs remain available and no hardcoded filters are substituted. Filter-schema results are not persisted because the project has no established typed cache pattern for API contracts.

## Not supported

- Filter condition operators other than `has_value`.
- Recommended pagination or unsupported recommended search/filter parameters.
- Saved jobs, because no confirmed saved-jobs endpoint exists in the current API layer.
