<?php

namespace App\Services\Assistant\Tools;

use App\Models\Project;

/**
 * Find projects whose titles are similar to a given title. Answers questions
 * like "هل يوجد مشاريع بعناوين مشابهة لـ ...؟" before approving a new title.
 *
 * Strategy: normalize Arabic text, then score every project title with both a
 * shared-token ratio and PHP similar_text() percent, and return the top matches
 * above a threshold.
 */
class FindSimilarProjectsTool extends Tool
{
    public function name(): string
    {
        return 'find_similar_projects';
    }

    public function description(): string
    {
        return 'البحث عن مشاريع بعناوين مشابهة لعنوان معيّن، مع درجة تشابه لكل نتيجة. مفيد لكشف تكرار/تشابه عناوين المشاريع.';
    }

    public function parameters(): array
    {
        return [
            'type' => 'object',
            'properties' => [
                'title' => [
                    'type' => 'string',
                    'description' => 'العنوان المراد البحث عن مشابهات له.',
                ],
                'limit' => [
                    'type' => 'integer',
                    'description' => 'أقصى عدد نتائج (افتراضي 10).',
                ],
            ],
            'required' => ['title'],
        ];
    }

    public function handle(array $args): array
    {
        $title = trim((string) ($args['title'] ?? ''));

        if ($title === '') {
            return ['error' => 'العنوان (title) مطلوب.'];
        }

        $needle = $this->normalize($title);
        $needleTokens = array_filter(explode(' ', $needle));

        $results = [];

        Project::query()
            ->with(['supervisor', 'type'])
            ->withCount('teams')
            ->select(['id', 'title', 'status', 'type_id', 'supervisor_id', 'difficulty_level'])
            ->chunk(200, function ($projects) use ($needle, $needleTokens, &$results) {
                foreach ($projects as $project) {
                    $candidate = $this->normalize($project->title);

                    // 1) character-level similarity percentage
                    similar_text($needle, $candidate, $percent);

                    // 2) shared-token (Jaccard) ratio to catch reordered wording
                    $candidateTokens = array_filter(explode(' ', $candidate));
                    $tokenRatio = $this->jaccard($needleTokens, $candidateTokens);

                    // blended score (0..100), weighting token overlap a bit higher
                    $score = round((0.45 * $percent) + (0.55 * $tokenRatio * 100), 1);

                    if ($score >= 35) {
                        $results[] = [
                            'project' => $this->formatProjectSummary($project),
                            'similarity' => $score,
                        ];
                    }
                }
            });

        usort($results, fn ($a, $b) => $b['similarity'] <=> $a['similarity']);

        return [
            'query' => $title,
            'count' => count($results),
            'matches' => array_slice($results, 0, $this->limit($args, 10)),
        ];
    }

    /** Jaccard similarity between two token sets. */
    private function jaccard(array $a, array $b): float
    {
        $a = array_unique($a);
        $b = array_unique($b);

        if (empty($a) || empty($b)) {
            return 0.0;
        }

        $intersection = count(array_intersect($a, $b));
        $union = count(array_unique(array_merge($a, $b)));

        return $union > 0 ? $intersection / $union : 0.0;
    }
}
