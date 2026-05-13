<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('projects', function (Blueprint $table) {
            $table->dropForeign(['advisor_id']);
            $table->dropColumn('advisor_id');
            $table->dropColumn('type');

            $table->foreignId('supervisor_id')->nullable()->constrained('users')->onDelete('set null');
            $table->foreignId('type_id')->nullable()->constrained('project_types')->onDelete('set null');
        });
    }

    public function down(): void
    {
        Schema::table('projects', function (Blueprint $table) {
            $table->dropForeign(['supervisor_id']);
            $table->dropForeign(['type_id']);
            $table->dropColumn('supervisor_id');
            $table->dropColumn('type_id');

            $table->string('type');
            $table->foreignId('advisor_id')->nullable()->constrained('users')->onDelete('set null');
        });
    }
};
