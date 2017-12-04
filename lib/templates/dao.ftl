package ${packageName}.dao.${package};

import android.arch.lifecycle.LiveData;
import android.arch.persistence.room.Dao;
import android.arch.persistence.room.Delete;
import android.arch.persistence.room.Insert;
import android.arch.persistence.room.OnConflictStrategy;
import android.arch.persistence.room.Query;
import android.arch.persistence.room.Update;
import java.util.List;

import ${packageName}.model.${package}.${name};
<#list dao.models as import>
import ${import};
</#list>
 
@Dao
public interface ${name}Dao {
    @Insert(onConflict=OnConflictStrategy.REPLACE)
    void add(${name} ${name?uncap_first});

    @Update(onConflict=OnConflictStrategy.REPLACE)
    void update(${name} ${name?uncap_first});

    @Delete
    void delete(${name} ${name?uncap_first});

    @Query("DELETE FROM `${name?lower_case}`")
    void deleteAll();

    @Query("SELECT * FROM `${name?lower_case}`<#if dao.orderBy??> ORDER BY ${dao.orderBy}<#if dao.orderByDirection??> ${dao.orderByDirection}</#if></#if>")
    LiveData<List<${name}>> getAll();

    @Query("SELECT * FROM `${name?lower_case}` WHERE `${primaryKeyMember.name}` = :${primaryKeyMember.memberName}")
    LiveData<${name}> get${name}By${primaryKeyMember.memberName?cap_first}(${primaryKeyMember.memberType} ${primaryKeyMember.memberName});
    <#list dao.queries as query>

    @Query("${query.sql}")
    LiveData<${query.returnType}> ${query.name}(${query.params[0].type} ${query.params[0].name}<#list query.params[1..] as member>, ${member.type} ${member.name}</#list>);
    </#list>

    // BEGIN PERSISTED SECTION - put custom methods here

    // END PERSISTED SECTION
}