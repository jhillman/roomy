package ${packageName}.dao.${package}

import android.arch.lifecycle.LiveData
import android.arch.persistence.room.Dao
import android.arch.persistence.room.Delete
import android.arch.persistence.room.Insert
import android.arch.persistence.room.OnConflictStrategy
import android.arch.persistence.room.Query
import android.arch.persistence.room.Update

import ${packageName}.model.${package}.${name}
<#list dao.models as import>
import ${import}
</#list>
 
@Dao
interface ${name}Dao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(${name?uncap_first}: ${name}): Long

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(${name?uncap_first}List: List<${name}>): List<Long>

    @Update
    fun update(${name?uncap_first}: ${name}): Int

    @Update
    fun update(${name?uncap_first}List: List<${name}>): Int

    @Delete
    fun delete(${name?uncap_first}: ${name}): Int

    @Query("DELETE FROM `${name?lower_case}`")
    fun deleteAll()

    @get:Query("SELECT * FROM `${name?lower_case}`<#if dao.orderBy??> ORDER BY `${dao.orderBy}`<#if dao.orderByDirection??> ${dao.orderByDirection}</#if></#if>")
    val all: LiveData<List<${name}>>

    @Query("SELECT * FROM `${name?lower_case}` WHERE `${primaryKeyMember.name}` = :${primaryKeyMember.memberName}")
    fun get${name}By${primaryKeyMember.memberName?cap_first}(${primaryKeyMember.memberName}: ${primaryKeyMember.memberType?cap_first}): LiveData<${name}>

    @Query("SELECT * FROM `${name?lower_case}` WHERE `${primaryKeyMember.name}` = :${primaryKeyMember.memberName}")
    fun get${name}By${primaryKeyMember.memberName?cap_first}Sync(${primaryKeyMember.memberName}: ${primaryKeyMember.memberType?cap_first}): ${name}
    <#list dao.queries as query>

    @Query("${query.sql}")
    fun ${query.name}(${query.params[0].name}: ${query.params[0].type?cap_first}<#list query.params[1..] as member>, ${member.name}: ${member.type?cap_first}</#list>): LiveData<${query.returnType}>
    </#list>

    // BEGIN PERSISTED SECTION - put custom methods here
${persistedSection}
    // END PERSISTED SECTION
}