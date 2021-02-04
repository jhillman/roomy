package ${packageName}.dao.${package}

import androidx.lifecycle.LiveData
import kotlinx.coroutines.flow.Flow
import androidx.room.*
import ${packageName}.model.${package}.${name}
<#list dao.models as import>
import ${import}
</#list>

/**
* AUTO-GENERATED CLASS.
* Make changes in <code>room.json</code> or use <code>PERSISTED SECTION</code> below
*/
 
@Dao
interface ${name}Dao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(${name?uncap_first}: ${name}): Long

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(${name?uncap_first}List: List<${name}>): List<Long>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAsync(${name?uncap_first}: ${name}): Long

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAsync(${name?uncap_first}List: List<${name}>): List<Long>

    @Update
    fun update(${name?uncap_first}: ${name}): Int

    @Update
    fun update(${name?uncap_first}List: List<${name}>): Int

    @Update
    suspend fun updateAsync(${name?uncap_first}: ${name}): Int

    @Update
    suspend fun updateAsync(${name?uncap_first}List: List<${name}>): Int

    @Delete
    fun delete(${name?uncap_first}: ${name}): Int

    @Query("DELETE FROM `${name?lower_case}` WHERE `${primaryKeyMember.name}` = :${primaryKeyMember.memberName}")
    fun deleteBy${primaryKeyMember.memberName?cap_first}Sync(${primaryKeyMember.memberName}: ${primaryKeyMember.memberType?cap_first}): Int

    @Query("DELETE FROM `${name?lower_case}` WHERE `${primaryKeyMember.name}` = :${primaryKeyMember.memberName}")
    suspend fun deleteBy${primaryKeyMember.memberName?cap_first}Async(${primaryKeyMember.memberName}: ${primaryKeyMember.memberType?cap_first}): Int

    @Query("DELETE FROM `${name?lower_case}`")
    fun deleteAll()

    @Delete
    suspend fun deleteAsync(${name?uncap_first}: ${name}): Int

    @Query("DELETE FROM `${name?lower_case}`")
    suspend fun deleteAllAsync()

    @get:Query("SELECT * FROM `${name?lower_case}`<#if dao.orderBy??> ORDER BY `${dao.orderBy}`<#if dao.orderByDirection??> ${dao.orderByDirection}</#if></#if>")
    val all: LiveData<List<${name}>>

    @Query("SELECT * FROM `${name?lower_case}`<#if dao.orderBy??> ORDER BY `${dao.orderBy}`<#if dao.orderByDirection??> ${dao.orderByDirection}</#if></#if>")
    suspend fun allAsync(): List<${name}>

    @get:Query("SELECT * FROM `${name?lower_case}`<#if dao.orderBy??> ORDER BY `${dao.orderBy}`<#if dao.orderByDirection??> ${dao.orderByDirection}</#if></#if>")
    val allFlow: Flow<List<${name}>>

    @Query("SELECT * FROM `${name?lower_case}` WHERE `${primaryKeyMember.name}` = :${primaryKeyMember.memberName}")
    fun get${name}By${primaryKeyMember.memberName?cap_first}(${primaryKeyMember.memberName}: ${primaryKeyMember.memberType?cap_first}): LiveData<${name}>

    @Query("SELECT * FROM `${name?lower_case}` WHERE `${primaryKeyMember.name}` = :${primaryKeyMember.memberName}")
    fun get${name}By${primaryKeyMember.memberName?cap_first}Sync(${primaryKeyMember.memberName}: ${primaryKeyMember.memberType?cap_first}): ${name}?

    @Query("SELECT * FROM `${name?lower_case}` WHERE `${primaryKeyMember.name}` = :${primaryKeyMember.memberName}")
    suspend fun get${name}By${primaryKeyMember.memberName?cap_first}Async(${primaryKeyMember.memberName}: ${primaryKeyMember.memberType?cap_first}): ${name}?
    <#list dao.queries as query>

    @Query("${query.sql}")
    fun ${query.name}(${query.params[0].name}: ${query.params[0].type?cap_first}<#list query.params[1..] as member>, ${member.name}: ${member.type?cap_first}</#list>): LiveData<${query.returnType}>

    @Query("${query.sql}")
    suspend fun ${query.name}Async(${query.params[0].name}: ${query.params[0].type?cap_first}<#list query.params[1..] as member>, ${member.name}: ${member.type?cap_first}</#list>): ${query.returnType}
    </#list>

    @Transaction
    suspend fun deleteAndInsert(items: List<${name}>) {
        deleteAllAsync()
        insertAsync(items)
    }
    
    @Transaction
    suspend fun deleteAndInsert(item: ${name}) {
        deleteAllAsync()
        insertAsync(item)
    }

    // BEGIN PERSISTED SECTION - put custom methods here
${persistedSection}
    // END PERSISTED SECTION
}